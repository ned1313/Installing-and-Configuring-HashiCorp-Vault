# Create Network Security Groups for subnets
resource "azurerm_network_security_group" "vault_net" {
  name                = local.vault_net_nsg
  location            = var.location
  resource_group_name = azurerm_resource_group.vault.name
}

resource "azurerm_subnet_network_security_group_association" "vault" {
  subnet_id                 = module.vnet.vnet_subnets[0]
  network_security_group_id = azurerm_network_security_group.vault_net.id
}

# Create Network Security Groups for NICs

resource "azurerm_network_security_group" "vault_nics" {
  name                = local.vault_nic_nsg
  location            = var.location
  resource_group_name = azurerm_resource_group.vault.name
}

# Create application security groups for Vault VMs

resource "azurerm_application_security_group" "vault_asg" {
  name                = local.vault_asg
  location            = var.location
  resource_group_name = azurerm_resource_group.vault.name
}

# Inbound rules for vault subnet nsg

resource "azurerm_network_security_rule" "vault_8200" {
  name                                       = "allow_8200"
  priority                                   = 100
  direction                                  = "Inbound"
  access                                     = "Allow"
  protocol                                   = "Tcp"
  source_port_range                          = "*"
  destination_port_range                     = "8200"
  source_address_prefix                      = "*"
  destination_application_security_group_ids = [azurerm_application_security_group.vault_asg.id]
  resource_group_name                        = azurerm_resource_group.vault.name
  network_security_group_name                = azurerm_network_security_group.vault_net.name
}

resource "azurerm_network_security_rule" "vault_8201" {
  name                                       = "allow_8201"
  priority                                   = 110
  direction                                  = "Inbound"
  access                                     = "Allow"
  protocol                                   = "Tcp"
  source_port_range                          = "*"
  destination_port_range                     = "8201"
  source_application_security_group_ids      = [azurerm_application_security_group.vault_asg.id]
  destination_application_security_group_ids = [azurerm_application_security_group.vault_asg.id]
  resource_group_name                        = azurerm_resource_group.vault.name
  network_security_group_name                = azurerm_network_security_group.vault_net.name
}

resource "azurerm_network_security_rule" "vault_ssh" {
  name                                       = "allow_ssh"
  priority                                   = 120
  direction                                  = "Inbound"
  access                                     = "Allow"
  protocol                                   = "Tcp"
  source_port_range                          = "*"
  destination_port_range                     = "22"
  source_address_prefix                      = "${data.http.my_ip.body}/32" # Restrict to your public IP address
  destination_application_security_group_ids = [azurerm_application_security_group.vault_asg.id]
  resource_group_name                        = azurerm_resource_group.vault.name
  network_security_group_name                = azurerm_network_security_group.vault_net.name
}

# Inbound rules for vault nic nsg

resource "azurerm_network_security_rule" "vault_nic_8200" {
  name                                       = "allow_8200"
  priority                                   = 100
  direction                                  = "Inbound"
  access                                     = "Allow"
  protocol                                   = "Tcp"
  source_port_range                          = "*"
  destination_port_range                     = "8200"
  source_address_prefix                      = "*"
  destination_application_security_group_ids = [azurerm_application_security_group.vault_asg.id]
  resource_group_name                        = azurerm_resource_group.vault.name
  network_security_group_name                = azurerm_network_security_group.vault_nics.name
}

resource "azurerm_network_security_rule" "vault_nic_8201" {
  name                                       = "allow_8201"
  priority                                   = 110
  direction                                  = "Inbound"
  access                                     = "Allow"
  protocol                                   = "Tcp"
  source_port_range                          = "*"
  destination_port_range                     = "8201"
  source_application_security_group_ids      = [azurerm_application_security_group.vault_asg.id]
  destination_application_security_group_ids = [azurerm_application_security_group.vault_asg.id]
  resource_group_name                        = azurerm_resource_group.vault.name
  network_security_group_name                = azurerm_network_security_group.vault_nics.name
}

resource "azurerm_network_security_rule" "vault_nic_ssh" {
  name                                       = "allow_ssh"
  priority                                   = 120
  direction                                  = "Inbound"
  access                                     = "Allow"
  protocol                                   = "Tcp"
  source_port_range                          = "*"
  destination_port_range                     = "22"
  source_address_prefix                      = "${data.http.my_ip.body}/32" # Restrict to your public IP address
  destination_application_security_group_ids = [azurerm_application_security_group.vault_asg.id]
  resource_group_name                        = azurerm_resource_group.vault.name
  network_security_group_name                = azurerm_network_security_group.vault_nics.name
}