output "resource_group_name" {
  value = azurerm_resource_group.aks.name
}

output "cluster_name" {
  value = local.aks_cluster_name
}