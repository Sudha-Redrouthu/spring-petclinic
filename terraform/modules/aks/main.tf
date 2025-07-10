resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix

  default_node_pool {
   name       = "default"
   node_count = 2
   vm_size    = "Standard_B2s"   # ✅ Change from Standard_DS2_v2 to Standard_B2s
   vnet_subnet_id = var.subnet_id
   }


  identity {
    type = "SystemAssigned"
  }

 network_profile {
  network_plugin     = "azure"
  service_cidr       = "10.1.0.0/16"        # ✅ Must NOT overlap with VNet/Subnet
  dns_service_ip     = "10.1.0.10"          # ✅ Must be within service_cidr
  docker_bridge_cidr = "172.17.0.1/16"
 }


}
