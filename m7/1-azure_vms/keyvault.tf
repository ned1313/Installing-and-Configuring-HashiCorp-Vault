
# Get your current IP address to provide access to Key Vault in the network acls
data "http" "my_ip" {
  url = "http://ifconfig.me"
}

# Create key vault and access policies
resource "azurerm_key_vault" "vault" {
  name                       = local.key_vault_name
  location                   = var.location
  resource_group_name        = azurerm_resource_group.vault.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  enabled_for_deployment     = true
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  sku_name = "standard"

  # Only allow access to the Key Vault from your public IP address and the vault 
  # subnet.
  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = ["${data.http.my_ip.body}/32"]
    virtual_network_subnet_ids = [module.vnet.vnet_subnets[0]]

  }

}

# Access policy for vault VMs
# Uses the vault user assigned identity
resource "azurerm_key_vault_access_policy" "vault" {
  key_vault_id = azurerm_key_vault.vault.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_user_assigned_identity.vault.principal_id

  key_permissions = [
    "get", "list", "update", "create", "decrypt", "encrypt", "unwrapKey", "wrapKey", "verify", "sign",
  ]

  secret_permissions = [
    "get", "list",
  ]

  certificate_permissions = [
    "get", "list",
  ]
}

# Access policy allowing your credentials full access to Key Vault
resource "azurerm_key_vault_access_policy" "you" {
  key_vault_id = azurerm_key_vault.vault.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  key_permissions = [
    "get", "list", "update", "create", "decrypt", "encrypt", "unwrapKey", "wrapKey", "verify", "sign", "delete", "purge",
  ]

  secret_permissions = [
    "get", "list", "set", "delete", "purge",
  ]

  certificate_permissions = [
    "get", "list", "create", "import", "delete", "update", "purge",
  ]
}

# Create a key for Vault autounseal
resource "azurerm_key_vault_key" "autounseal" {
  depends_on   = [azurerm_key_vault_access_policy.you]
  name         = "${local.resource_group_name}-autounseal"
  key_vault_id = azurerm_key_vault.vault.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

# Create a certificate in Key Vault for the Vault server
resource "azurerm_key_vault_certificate" "vault" {
  depends_on   = [azurerm_key_vault_access_policy.you]
  name         = "${local.resource_group_name}-cert"
  key_vault_id = azurerm_key_vault.vault.id

  certificate {
    contents = filebase64(var.cert_pfx_file_path)
    password = ""
  }

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = false
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }
  }
}


