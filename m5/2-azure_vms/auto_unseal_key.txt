locals {
  unseal_key_name = "vault-${random_id.id.hex}"
}

resource "azurerm_key_vault_key" "unseal_key" {
  name         = local.unseal_key_name
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

resource "local_file" "seal_config" {
  filename = "${path.module}/seal.hcl"
  content = <<EOF
seal "azurekeyvault" {
  tenant_id      = "${data.azurerm_client_config.current.tenant_id}"
  vault_name     = "${azurerm_key_vault.vault.name}"
  key_name       = "${azurerm_key_vault_key.unseal_key.name}"
}
  EOF
}