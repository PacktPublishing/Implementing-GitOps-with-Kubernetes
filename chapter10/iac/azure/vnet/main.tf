provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "gitops_terraform_rg" {
  name     = "gitops-terraform-rg"
  location = "switzerlandnorth"
}

resource "azurerm_virtual_network" "gitops_terraform_vnet" {
  name                = "gitops-terraform-vnet"
  resource_group_name = azurerm_resource_group.gitops_terraform_rg.name
  location            = azurerm_resource_group.gitops_terraform_rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "default_subnet" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.gitops_terraform_rg.name
  virtual_network_name = azurerm_virtual_network.gitops_terraform_vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "azure_bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.gitops_terraform_rg.name
  virtual_network_name = azurerm_virtual_network.gitops_terraform_vnet.name
  address_prefixes     = ["10.0.2.0/26"]
}