# Create a Resource Group
resource "azurerm_resource_group" "aks" {
  name     = "aks-k8s-deployments-rg"
  location = "switzerlandnorth"
}

# Create Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = "aksgitops3003204acr"
  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  sku                 = "Basic"
  admin_enabled       = false
}

# Create Azure Kubernetes Service
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aksgitopscluster"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = "aksgitopscluster"
  sku_tier            = "Free"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }
}

# Attach ACR to AKS using role assignment
resource "azurerm_role_assignment" "acr_attach" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}