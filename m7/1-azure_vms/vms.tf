# Generate key pair for all VMs
resource "tls_private_key" "vault" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

# Write private key out to a file
resource "local_file" "private_key" {
  content  = tls_private_key.vault.private_key_pem
  filename = "${path.root}/azure_vms_private_key.pem"
}

# Create User Identities for Vault VMs
resource "azurerm_user_assigned_identity" "vault" {
  resource_group_name = azurerm_resource_group.vault.name
  location            = var.location

  name = local.vault_user_id
}

##################### vault VM RESOURCES ###################################
resource "azurerm_availability_set" "vault" {
  name                         = local.vault_vm
  location                     = var.location
  resource_group_name          = azurerm_resource_group.vault.name
  platform_fault_domain_count  = 3
  platform_update_domain_count = 2
  managed                      = true
}


resource "azurerm_network_interface" "vault" {
  count               = var.vault_vm_count
  name                = "${local.vault_vm}-${count.index}"
  location            = var.location
  resource_group_name = azurerm_resource_group.vault.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.vnet.vnet_subnets[0]
    private_ip_address_allocation = "Dynamic"
  }
}

# Associate the network interfaces from the vaults with the vault NSG
resource "azurerm_network_interface_security_group_association" "vault" {
  count                     = var.vault_vm_count
  network_interface_id      = azurerm_network_interface.vault[count.index].id
  network_security_group_id = azurerm_network_security_group.vault_nics.id
}

# Associate the network interfaces from the vaults with the vault ASG for NSG rules
resource "azurerm_network_interface_application_security_group_association" "vault" {
  count                         = var.vault_vm_count
  network_interface_id          = azurerm_network_interface.vault[count.index].id
  application_security_group_id = azurerm_application_security_group.vault_asg.id
}

resource "azurerm_linux_virtual_machine" "vault" {
  count               = var.vault_vm_count
  name                = "${local.vault_vm}-${count.index}"
  location            = var.location
  resource_group_name = azurerm_resource_group.vault.name
  size                = var.vault_vm_size
  admin_username      = "azureuser"
  computer_name       = "vault-${count.index}"
  availability_set_id = azurerm_availability_set.vault.id
  network_interface_ids = [
    azurerm_network_interface.vault[count.index].id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.vault.public_key_openssh
  }

  # Using Standard SSD tier storage
  # Accepting the standard disk size from image
  # No data disk is being used
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  #Source image is hardcoded b/c I said so
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.vault.id]
  }

  #Custom data from the vault.tmpl file
  custom_data = base64encode(
    templatefile("${path.module}/vault.tpl", {
      vault_version         = var.vault_version
      tenant_id             = data.azurerm_client_config.current.tenant_id
      leader_tls_servername = var.leader_tls_servername
      key_vault_name        = local.key_vault_name
      key_vault_key_name    = azurerm_key_vault_key.autounseal.name
      key_vault_secret_id   = azurerm_key_vault_certificate.vault.secret_id
    })
  )
}