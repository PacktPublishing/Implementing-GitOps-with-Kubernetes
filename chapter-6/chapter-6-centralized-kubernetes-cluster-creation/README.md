# 0. Preparation steps

## Install the following tools:

- kubectl
- clusterctl
- az
- helm

# 1. Initialize the management cluster

    export AZURE_SUBSCRIPTION_ID="<SubscriptionId>"

## Create an Azure Service Principal and paste the output here

    export AZURE_TENANT_ID="<Tenant>"
    export AZURE_CLIENT_ID="<AppId>"
    export AZURE_CLIENT_SECRET="<Password>"

## Base64 encode the variables

    export AZURE_SUBSCRIPTION_ID_B64="$(echo -n "$AZURE_SUBSCRIPTION_ID" | base64 | tr -d '\n')"
    export AZURE_TENANT_ID_B64="$(echo -n "$AZURE_TENANT_ID" | base64 | tr -d '\n')"
    export AZURE_CLIENT_ID_B64="$(echo -n "$AZURE_CLIENT_ID" | base64 | tr -d '\n')"
    export AZURE_CLIENT_SECRET_B64="$(echo -n "$AZURE_CLIENT_SECRET" | base64 | tr -d '\n')"

## Settings needed for AzureClusterIdentity used by the AzureCluster

    export AZURE_CLUSTER_IDENTITY_SECRET_NAME="cluster-identity-secret"
    export CLUSTER_IDENTITY_NAME="cluster-identity"
    export AZURE_CLUSTER_IDENTITY_SECRET_NAMESPACE="default"

## Create a secret to include the password of the Service Principal identity created in Azure

## This secret will be referenced by the AzureClusterIdentity used by the AzureCluster

    kubectl create secret generic "${AZURE_CLUSTER_IDENTITY_SECRET_NAME}" --from-literal=clientSecret="${AZURE_CLIENT_SECRET}" --namespace "${AZURE_CLUSTER_IDENTITY_SECRET_NAMESPACE}"

## Finally, initialize the management cluster

    clusterctl init --infrastructure azure

# 2. Create your first workload cluster

## Name of the Azure datacenter location. Change this value to your desired location.

    export AZURE_LOCATION="westeurope"

## Select VM types.

    export AZURE_CONTROL_PLANE_MACHINE_TYPE="Standard_D2s_v3"
    export AZURE_NODE_MACHINE_TYPE="Standard_D2s_v3"

## [Optional] Select resource group. The default value is ${CLUSTER_NAME}.

    export AZURE_RESOURCE_GROUP="<ResourceGroupName>"

## Generating the cluster configuration

    clusterctl generate cluster capi-quickstart \
    --kubernetes-version v1.29.0 \
    --control-plane-machine-count=1 \
    --worker-machine-count=3 \
    > capi-quickstart.yaml

# 3. Deploy the workload cluster

_NOTE: You should do it the GitOps way._

    kubectl apply -f capi-quickstart.yaml

# 4. Deploy Calico CNI

First, check if the kubeadmcontrolplane is ready:

    clusterctl describe cluster capi-quickstart

You should get an output similar to this:

    NAME                                                                READY  SEVERITY  REASON                       SINCE  MESSAGE
    Cluster/capi-quickstart                                             True                                          11s
    ├─ClusterInfrastructure - AzureCluster/capi-quickstart              True                                          2m34s
    ├─ControlPlane - KubeadmControlPlane/capi-quickstart-control-plane  True                                          11s
    │ └─Machine/capi-quickstart-control-plane-dct9z                     True                                          12s
    └─Workers
    └─MachineDeployment/capi-quickstart-md-0                          False  Warning   WaitingForAvailableMachines  5m4s   Minimum availability requires 3 replicas, current 0 available
        └─3 Machines...                                                 False  Info      WaitingForBootstrapData      3s

After the first control plane node is up and running, we can retrieve the workload cluster Kubeconfig.

    clusterctl get kubeconfig capi-quickstart > capi-quickstart.kubeconfig

Now Install Calico CNI with:

    helm repo add projectcalico https://docs.tigera.io/calico/charts --kubeconfig=./capi-quickstart.kubeconfig && \
    helm install calico projectcalico/tigera-operator --kubeconfig=./capi-quickstart.kubeconfig -f https://raw.githubusercontent.com/kubernetes-sigs/cluster-api-provider-azure/main/templates/addons/calico/values.yaml --namespace tigera-operator --create-namespace

After a short while, nodes should be running and in Ready state, let’s check the status using kubectl get nodes

    kubectl get nodes --kubeconfig=./capi-quickstart.kubeconfig
