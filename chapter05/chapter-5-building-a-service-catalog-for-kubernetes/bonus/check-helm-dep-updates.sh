#!/bin/bash
set -eo pipefail

DEBUG=${DEBUG:-"n"}
if [[ "$DEBUG" =~ ^([yY])+$ ]]; then
    set -x
fi

DIRNAME="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

pushd $DIRNAME >/dev/null

file="dependencies.yaml"

function setEnvsWithConfigFromFile() {
    # Gets the settings and creates a string to define local variables
    eval $(echo "${dependencies}" | yq e '.config | to_entries | map(.key + "=" + .value) | join(" ")')
}

# -------- functions ------------ #

function readDependenciesFromFile() {
    # Get the number of dependencies
    count=$(echo "${dependencies}" | yq e '.dependencies | length')

}

function setSourceBranch() {

    # Set the source branch
    git checkout $BRANCH
}

function checkHelmDependencies() {
    for ((i = 0; i < $count; i++)); do

        dependencyPath=".dependencies[$(echo "${dependencies}" | yq e ".dependencies[$i].arrayPosition // 0")]"
        chartSourcePath=$(echo "${dependencies}" | yq e ".dependencies[$i].sourcePath")

        # Name of the dependency like External DNS
        name=$(echo "${dependencies}" | yq e ".dependencies[$i].name")
        # Path to the Chart.yaml file
        chart_file=$chartSourcePath/Chart.yaml
        # Path to the version number in the Chart.yaml file like 6.20.0
        version_path="${dependencyPath}.version"
        # Repository name for the Artifact API
        repo_name=$(echo "${dependencies}" | yq e ".dependencies[$i].repositoryName")
        # Repository url for the Artifact API
        repo_url_path="${dependencyPath}.repository"

        # Sanitize the repo name
        sanitized_name=$(echo $repo_name | cut -d'/' -f1)

        #Change directory to the chart file directory
        pushd $chartSourcePath >/dev/null

        # Read the version from the Chart.yaml file
        version=$(yq e "$version_path" "$(basename $chart_file)")
        repo_url=$(yq e "$repo_url_path" "$(basename $chart_file)")

        # Add the repo to helm
        helm repo add $sanitized_name $repo_url || true
        helm repo update 1 &>/dev/null || true

        #Get the latest version with the Artifact API
        latest_version=$(helm search repo $repo_name --output yaml | yq e '.[0].version')

        # Output
        echo "Name: $name"
        echo "Version in Chart.yaml: $version"
        echo "Latest Version in Repository: $latest_version"

        diffBetweenVersions

        # Return to the original directory
        popd >/dev/null
    done
}

function diffBetweenVersions() {
    if [ "$version" != "$latest_version" ]; then

        # Delete local branch if it already exists
        git branch -D $tplBranchName 2>/dev/null || true
        # Fetch the latest changes from the remote
        git fetch origin --prune
        # Get the current branch name
        tplBranchName=update-helm-$sanitized_name-$latest_version

        if [[ -n $(git show-ref $tplBranchName) ]] && [[ "$DRY_RUN" != "true" ]]; then

            echo "[-] Pull request or branch $tplBranchName already exists"

        else
            echo "There's a difference between the versions."

            tempDir=$(mktemp -d)

            diffValuesFile="${tempDir}/diff_value.yaml"
            diffLatestValuesFile="${tempDir}/diff_latest_value.yaml"
            diffResultFile="${tempDir}/diff_result.txt"
            shiftDiffResultFile="${tempDir}/shift_diff_result.txt"

            # Get values from the repo
            helm show values $repo_name --version $version >$diffValuesFile
            helm show values $repo_name --version $latest_version >$diffLatestValuesFile

            dyff between $diffValuesFile $diffLatestValuesFile >$diffResultFile

            awk '{ printf "\t%s\n", $0 }' $diffResultFile >$shiftDiffResultFile
            shift_diff_result=$(cat $shiftDiffResultFile)

            # If the diff output is too large for display, overwrite it with a message
            if ((${#shift_diff_result} > 4000)) && [ "$AZURE_DEVOPS" == "true" ]; then
                echo "The diff output is too large for display (>4000 characters).
                Please refer to ArtifactHub directly for a detailed comparison of
                changes between the $version and $latest_version." >$shiftDiffResultFile
            fi

            if [ "$DRY_RUN" == "true" ]; then
                dryRun
            elif [ "$WITHOUT_PR" == "true" ]; then
                withOutPR
            elif [ "$GITHUB" == "true" ]; then
                gitHubPR
            elif [ "$AZURE_DEVOPS" == "true" ]; then
                azureDevOps
            fi

            rm -rf $tempDir

        fi
    else
        echo "There's no difference between the versions."
    fi
}

function updateVersionInChartFile() {
    # Replace the old version with the new version in the Chart.yaml file using sed
    yq e -i "$version_path = \"$latest_version\"" "$(basename $chart_file)"
}

function createCommitAndPushBranch() {
    # Create a new branch for this change
    git checkout -b $tplBranchName

    # Add the changes to the staging area
    git add "$(basename $chart_file)"

    # Create a commit with a message indicating the changes
    git commit -m "Update $name version from $version to $latest_version"

    # Push the new branch to GitHub
    git push origin $tplBranchName
}

function withOutPR() {
    updateVersionInChartFile
    createCommitAndPushBranch
}

function gitHubPR() {
    updateVersionInChartFile
    createCommitAndPushBranch

    gh pr create \
        --title "Update $name version from $version to $latest_version" \
        --body "$shift_diff_result" \
        --base $BRANCH \
        --head $tplBranchName || true

    # Get back to the source branch
    git checkout $BRANCH
}

function azureDevOps() {
    updateVersionInChartFile
    createCommitAndPushBranch

    # Create a Azure DevOps Pull Request
    az repos pr create \
        --title "Update $name version from $version to $latest_version" \
        --description "$shift_diff_result" \
        --target-branch $BRANCH \
        --source-branch $tplBranchName 1>/dev/null || true

    # Get back to the source branch
    git checkout $BRANCH

}

function dryRun() {
    cat $diffResultFile
}

function errorEcho {
    echo "ERROR: ${1}" 1>&2
    exit 1
}

function infoEcho {
    echo "${1}"
}

function errorUsage {
    cat <<-EOF
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
|                                 ERROR: ${1}                                 |
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
EOF

    usage
    exit 1
}

function usage() {
    cat <<-EOF

please set all necessary propertis in $file file.
--------------- necessary-keys: -------------------

config:
  BRANCH: main
  DRY_RUN: true
  GITHUB: false
  AZURE_DEVOPS: false
  WITHOUT_PR: false
EOF
}

function start() {
    # Set the source branch
    setSourceBranch
    # Read the file
    readDependenciesFromFile
    # Check if the dependencies are up to date
    checkHelmDependencies
}

# -------- Check Prerequisites ------------ #
declare -a defaultDependencies=(
    "yq"
    "dyff"
    "helm"
    "git"
)

if [ "$GITHUB" == "true" ]; then
    defaultDependencies+=("gh")
fi

if [ "$AZURE_DEVOPS" == "true" ]; then
    defaultDependencies+=("az")
fi

for cmd in ${defaultDependencies[*]}; do
    command -v ${cmd} >/dev/null || {
        echo >&2 "${cmd} must be installed - exiting..."
        exit 1
    }
done

while [[ $# -gt 0 ]]; do
    key="${1}"

    case $key in
    --help | -h | help)
        usage
        exit 0
        ;;
    *)
        shift
        ;;
    esac
done

# -------- check file exists check and load config ------------ #

if [[ -f $file ]]; then
    echo "Loading dependencies from $file"
    dependencies=$(yq e . $file)
    setEnvsWithConfigFromFile
else
    echo "Error: Dependencies file $file not found!"
fi

# -------- environments check  ------------ #

# Abort if required arguments are empty
if [[ -z ${BRANCH} || ${BRANCH} == '<no value>' ]]; then
    errorUsage "BRANCH missing!"
fi

if [[ -z ${DRY_RUN} || ${DRY_RUN} == '<no value>' ]]; then
    errorUsage "DRY_RUN missing!"
fi

if [[ -z ${GITHUB} || ${GITHUB} == '<no value>' ]]; then
    errorUsage "GITHUB missing!"
fi

if [[ -z ${AZURE_DEVOPS} || ${AZURE_DEVOPS} == '<no value>' ]]; then
    errorUsage "AZURE_DEVOPS missing!"
fi

if [[ -z ${WITHOUT_PR} || ${WITHOUT_PR} == '<no value>' ]]; then
    errorUsage "WITHOUT_PR missing!"
fi

# -------- Main  ------------ #
start

popd >/dev/null
