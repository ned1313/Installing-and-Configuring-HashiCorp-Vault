# Resource group for the AKS cluster
resource "azurerm_resource_group" "aks" {
  name = local.resource_group_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "aks" {
  name = local.aks_cluster_name
  location = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix = local.aks_dns_prefix

  kubernetes_version = var.aks_kubernetes_version

  default_node_pool {
    name = "default"
    node_count = var.node_count
    vm_size = var.node_size
  }

  identity {
    type = "SystemAssigned"
  }
}