resource "azurerm_resource_group" "vault" {
  name     = local.resource_group_name
  location = var.location
}

# Virtual network with a Vault subnet
module "vnet" {
  source              = "Azure/vnet/azurerm"
  version             = "~> 2.0"
  resource_group_name = azurerm_resource_group.vault.name
  vnet_name           = azurerm_resource_group.vault.name
  address_space       = var.address_space
  subnet_prefixes     = var.subnet_prefixes
  subnet_names        = var.subnet_names

  subnet_service_endpoints = {
    (var.subnet_names[0]) = ["Microsoft.KeyVault"]
  }

}

resource "azurerm_nat_gateway" "vault" {
  location            = var.location
  name                = local.nat_gateway_name
  resource_group_name = azurerm_resource_group.vault.name
  sku_name            = "Standard"
}

resource "azurerm_public_ip" "vault_nat" {
  allocation_method   = "Static"
  location            = var.location
  name                = "${local.nat_gateway_name}-vault-nat"
  resource_group_name = azurerm_resource_group.vault.name
  sku                 = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "vault" {
  nat_gateway_id       = azurerm_nat_gateway.vault.id
  public_ip_address_id = azurerm_public_ip.vault_nat.id
}

resource "azurerm_subnet_nat_gateway_association" "vault" {
  nat_gateway_id = azurerm_nat_gateway_public_ip_association.vault.nat_gateway_id
  subnet_id      = module.vnet.vnet_subnets[0]
}