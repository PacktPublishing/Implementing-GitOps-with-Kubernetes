# Helm Dependencies Update Helper (Script)

This is a script to help you to update your helm dependencies in your helm charts. It will create a PR with the changes if you want to. But

Why I build this tool? We have a lot of helm charts and we want to update the dependencies in all of them.
The resources from helm-charts will be deployed over argocd, so the helm chart will no be installed on the cluster itself.
Because of that you cant use tools like [renovate](https://github.com/renovatebot/helm-charts) or [dependabot](https://github.com/dependabot) running in the cluster.
Since recently you can use renovate to update helm-values and maybe you like to use this tool instead of this script.

You can use this tool in your CI/CD pipeline or locally.

## Requirements

You will need the following tools installed on your machine (depends on your target environment):

- [yq](https://github.com/mikefarah/yq)
- [dyff](https://github.com/homeport/dyff)
- [az cli](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- [azure-devops cli](https://learn.microsoft.com/en-us/azure/devops/cli/?view=azure-devops)
- [gh cli](https://cli.github.com/manual/installation)
- [helmv3](https://helm.sh/docs/intro/install/)

Please feel to fork this repository. This allows you to customize the script for your needs. Moreover you test the script directly in your environment.

## Dry-Run

The default for the key `config` in the `dependencies.yaml` files looks like:

```yaml
config:
  BRANCH: main
  DRY_RUN: true
  GITHUB: false
  AZURE_DEVOPS: false
  WITHOUT_PR: false
```

This will only print the changes to the console. You can run the script with:

```shell
./check-helm-dep-updates.sh
```

You will get an output like:

```
 ####################### Begin #######################
 Name: External DNS
 Version in Chart.yaml: 6.20.4
 Latest Version in Repository: 6.21.0
 There's a difference between the versions.
 Differences:
     _        __  __
   _| |_   _ / _|/ _|  between values.yaml
 / _' | | | | |_| |_       and latest_values.yaml
| (_| | |_| |  _|  _|
 \__,_|\__, |_| |_|   returned two differences
        |___/

 (root level)
 + one map entry added:
 ## @param ingressClassFilters Filter sources managed by external-dns via IngressClass (optional)
 ##
 ingressClassFilters: []

 image.tag
 ± value change
     - 0.13.4-debian-11-r19
     + 0.13.5-debian-11-r55

 ####################### End #######################
```

## GitHub

First you have to login against GitHub. You can do this with `gh auth login` or get more information here on the official [documentation](https://cli.github.com/manual/gh_auth_login)

Now edit the key `config` in `dependencies.yaml` file like:

```yaml
config:
  BRANCH: main
  DRY_RUN: false
  GITHUB: true
  AZURE_DEVOPS: false
  WITHOUT_PR: false
```

Commit and push the changes to your repository. After that you can run the script with:

> **Warning**
>
> After you set `GITHUB` to `true`, the script will create a new branch and a PR with the changes. If you want to test it first, set `DRY_RUN` to `true`.

Execute the script with:

```shell
./check-helm-dep-updates.sh
```

Check the changes on GitHub and if you are happy with them, you can merge the PR.

## Azure DevOps

First you have to create a PAT token. You can find more information here on the official [documentation](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=preview-page). After you created the PAT token, you need to set the following variable:

```shell
AZURE_DEVOPS_EXT_PAT=<your-pat-token>
```

Now edit the key `config` in `dependencies.yaml` file like:

```yaml
config:
  BRANCH: main
  DRY_RUN: true
  GITHUB: false
  AZURE_DEVOPS: true
  WITHOUT_PR: false
```

> **Warning**
>
> After you set `AZURE_DEVOPS` to `true`, the script will create a new branch and a PR with the changes. If you want to test it first, set `DRY_RUN` to `true`.

Execute the script with:

```shell
./check-helm-dep-updates.sh
```

Check the changes on Azure DevOps and if you are happy with them, you can merge the PR.

## Without PR - Support all Git Providers

This part allows you to update the helm dependencies without creating a PR. You can use this part in your CI/CD pipeline.
It can be useful if you want to update the helm dependencies in your main branch over an manual pull request.

Now edit the key `config` in `dependencies.yaml` file like:

```yaml
config:
  BRANCH: main
  DRY_RUN: true
  GITHUB: false
  AZURE_DEVOPS: false
  WITHOUT_PR: true
```

> **Warning**
>
> After you set `WITHOUT_PR` to `true`, the script will create a new branch and push this branch. If you want to test it first, set `DRY_RUN` to `true`.

Execute the script with:

```shell
./check-helm-dep-updates.sh
```

Check the changes on your Git Provider and if you are happy with them, you can merge the PR.

## The CI/CD Way

Naturally, you’d want everything to be automated, and the only task on your plate would be to review the pull request. Here’s where CI/CD (Continuous Integration/Continuous Deployment) fits in like a glove.

### Azure DevOps Pipelines

Under the folder azure-devops you will find a pipeline file. You can use this folder structure in your Azure DevOps project.
You should replace the `orga` parameter with your organization and like `https://dev.azure.com/<YOUR_ORGA_NAME>/<YOUR_PPROJECT_NAME>/_git/<YOUR_REPO_NAME>`.

### GitHub Actions

You can use this script as a [GitHub action](https://github.com/la-cc/gh-actions) in your repository.
To do this, you need only to create a new workflow file in your repository under `.github/workflows/` and add the following content:

```yaml
name: helm-dependencies

on:
  workflow_dispatch:
  schedule:
    - cron: "0 0 * * *"
  push:
    branches:
      - main
    paths:
      - ".github/workflows/helm-dependencies.yml"
      - "dependencies.yaml"

jobs:
  helm-dependencies:
    name: Helm Dependencies
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Helm Dependencies
        uses: la-cc/gh-actions/helm-dependencies@v0.0.8
        with:
          config-path: dependencies.yaml
          user-email: "meep-the-helm-bot@users.noreply.github.com"
          user-name: "Meep"
          default-branch: "main"
          dry-run: false
          github-run: true
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

Of course you will be need a `dependencies.yaml` file in your repository. You can use the example file from this [repository](https://github.com/la-cc/kubernetes-service-catalog-dep-test).

## Contributing

If you're eager to contribute to this script, feel free to fork the repository and submit a pull request. Your input is valued and always welcome!

**Current Contributors:**

- @[jullianow](https://github.com/jullianow)
- @[la-cc](https://github.com/la-cc)
