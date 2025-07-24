# This resource creates the managed identity in Azure.
resource "azurerm_user_assigned_identity" "aks" {
  name                = "${var.cluster_name}-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
}

# This resource creates the AKS cluster.
resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.cluster_name

  default_node_pool {
    name           = "default"
    node_count     = var.node_count
    vm_size        = "Standard_DS2_v2"
    vnet_subnet_id = var.vnet_subnet_id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  network_profile {
    network_plugin = "azure"
    service_cidr   = "10.0.2.0/24"
    dns_service_ip = "10.0.2.10"
  }
}

data "azurerm_subscription" "current" {}
