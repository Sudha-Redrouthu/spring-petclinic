
provider "azurerm" {
  features {}
}

module "resource_group" {
  source              = "./modules/resource_group"
  name                = var.resource_group_name
  location            = var.location
}

module "network" {
  source              = "./modules/network"
  resource_group_name = var.resource_group_name
  location            = var.location
  vnet_name           = var.vnet_name
  subnet_name         = var.subnet_name
  address_space       = var.address_space
  subnet_prefixes     = var.subnet_prefixes
}

module "aks" {
  source              = "./modules/aks"
  name                = var.aks_cluster_name
  dns_prefix          = var.dns_prefix
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = module.network.subnet_id
}
