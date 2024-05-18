#!/bin/bash

# Define the namespace where Argo CD is installed
NAMESPACE="argocd"

# Define the name of the secret where the initial password is stored
SECRET_NAME="argocd-initial-admin-secret"

export ARGO_CD_PASSWORD=""


# Function to get the Argo CD admin password
function get_argo_cd_password() {
    # Loop until the password is retrieved
    while true; do
        # Extract the password from the secret
        ARGO_CD_PASSWORD=$(kubectl get secret $SECRET_NAME -n $NAMESPACE -o jsonpath="{.data.password}" 2>/dev/null | base64 --decode)
        
        # Check if password is successfully retrieved and non-empty
        if [[ ! -z "$ARGO_CD_PASSWORD" ]]; then
            echo "Successfully retrieved the initial password for Argo CD."
            echo "Initial Admin Password: $ARGO_CD_PASSWORD"
            break  # Exit the loop if password is retrieved
        else
            echo "Waiting for the initial password to be set in the secret..."
            sleep 10  # Wait for 10 seconds before trying again
        fi
    done
}

# Check if the secret exists in the specified namespace
if kubectl get secret $SECRET_NAME -n $NAMESPACE &> /dev/null; then
    echo "Secret '$SECRET_NAME' found in namespace '$NAMESPACE'."
    get_argo_cd_password
else
    echo "Secret '$SECRET_NAME' not found in namespace '$NAMESPACE'."
    echo "Ensure Argo CD is installed and the secret name is correct."
    exit 1
fi
