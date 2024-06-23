
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "gitops_rg" {
  name     = var.rg
  location = var.location
}

resource "azurerm_virtual_network" "gitops_vnet" {
  name                = "gitops-${var.environment}-vnet"
  resource_group_name = azurerm_resource_group.gitops_rg.name
  location            = azurerm_resource_group.gitops_rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "default_subnet" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.gitops_rg.name
  virtual_network_name = azurerm_virtual_network.gitops_vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "gitops-${var.environment}-aks-subnet"
  resource_group_name  = azurerm_resource_group.gitops_rg.name
  virtual_network_name = azurerm_virtual_network.gitops_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_kubernetes_cluster" "gitops_aks" {
  name                    = "gitops-${var.environment}-aks"
  location                = azurerm_resource_group.gitops_rg.location
  resource_group_name     = azurerm_resource_group.gitops_rg.name
  dns_prefix              = "gitops-${var.environment}-aks"
  kubernetes_version      = "1.28.5"
  private_cluster_enabled = false

  default_node_pool {
    name            = "default"
    node_count      = 1
    vm_size         = "Standard_B2s"
    os_disk_size_gb = 30
    type            = "VirtualMachineScaleSets"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
  }

}

# Define an Azure Container Registry with the name gitops-terraform-acr in the same resource group as the AKS cluster.
# The SKU is set to Basic and the admin user is disabled.

resource "azurerm_container_registry" "gitops_acr" {
  name                = "gitops${var.environment}acr"
  resource_group_name = azurerm_resource_group.gitops_rg.name
  location            = azurerm_resource_group.gitops_rg.location
  sku                 = "Standard"
  admin_enabled       = false
}

# Define a role assignment to allow the AKS cluster to pull images from the ACR.

resource "azurerm_role_assignment" "gitops_acr_role" {
  scope                = azurerm_container_registry.gitops_acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.gitops_aks.kubelet_identity[0].object_id
}