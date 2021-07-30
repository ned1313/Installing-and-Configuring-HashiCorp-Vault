# The dns label from the load balancer
output "public_dns_name" {
  value = azurerm_public_ip.vault.fqdn
}

# The public IP address of the load balancer
output "public_ip_address" {
  value = azurerm_public_ip.vault.ip_address
}