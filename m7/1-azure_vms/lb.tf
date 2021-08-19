# Create a public IP address for the load balancer
# The domain label is based on the resource group name
resource "azurerm_public_ip" "vault" {
  name                = local.pip_name
  resource_group_name = azurerm_resource_group.vault.name
  location            = azurerm_resource_group.vault.location
  allocation_method   = "Static"
  domain_name_label   = lower(azurerm_resource_group.vault.name)
  sku                 = "Standard"
}

# Create a load balancer for vault to use
resource "azurerm_lb" "vault" {
  name                = local.lb_name
  location            = azurerm_resource_group.vault.location
  resource_group_name = azurerm_resource_group.vault.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.vault.id
  }
}

# Create an address pool for the Vault servers
resource "azurerm_lb_backend_address_pool" "pool" {
  loadbalancer_id = azurerm_lb.vault.id
  name            = "vault-servers"
}

# Associate all vault NICs with the backend pool
resource "azurerm_network_interface_backend_address_pool_association" "vault" {
  count                   = var.vault_vm_count
  backend_address_pool_id = azurerm_lb_backend_address_pool.pool.id
  ip_configuration_name   = "internal"
  network_interface_id    = azurerm_network_interface.vault[count.index].id
}

# All health probe for vault nodes
resource "azurerm_lb_probe" "vault_8200" {
  resource_group_name = azurerm_resource_group.vault.name
  loadbalancer_id     = azurerm_lb.vault.id
  name                = "port-8200"
  protocol            = "Https"
  port                = 8200
  request_path        = "/v1/sys/health?activecode=200&standbycode=429&sealedcode=200&uninitcode=200"
}

# Add LB rule for vault
resource "azurerm_lb_rule" "vault" {
  resource_group_name            = azurerm_resource_group.vault.name
  loadbalancer_id                = azurerm_lb.vault.id
  name                           = "vault"
  protocol                       = "Tcp"
  frontend_port                  = 8200
  backend_port                   = 8200
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.vault_8200.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.pool.id
}

# Add an NAT rule for the vault node using port 2022 
# This is so you can SSH into the vault to troubleshoot 
# deployment issues.
resource "azurerm_lb_nat_rule" "vault" {
  resource_group_name            = azurerm_resource_group.vault.name
  loadbalancer_id                = azurerm_lb.vault.id
  name                           = "ssh-vault"
  protocol                       = "Tcp"
  frontend_port                  = 2022
  backend_port                   = 22
  frontend_ip_configuration_name = "PublicIPAddress"
}

# Associate the NAT rule with the first vault VM
resource "azurerm_network_interface_nat_rule_association" "vault" {
  network_interface_id  = azurerm_network_interface.vault[0].id
  ip_configuration_name = "internal"
  nat_rule_id           = azurerm_lb_nat_rule.vault.id
}
