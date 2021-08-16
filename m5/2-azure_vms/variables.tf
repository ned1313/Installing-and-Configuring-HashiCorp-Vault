variable "location" {
  type    = string
  default = "East US"
}

variable "address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "subnet_prefixes" {
  type = list(string)
  default = [
    "10.0.0.0/24",
  ]
}

variable "subnet_names" {
  type = list(string)
  default = [
    "vault-servers",
  ]
}

variable "vault_vm_size" {
  type    = string
  default = "Standard_B2ms"
}

variable "vault_vm_count" {
  type    = number
  default = 1
}

variable "cert_pfx_file_path" {
  type        = string
  description = "The full path to the pfx file to be used for Vault"
  default     = "../1-cert-gen/vm-certificate-to-import.pfx"
}

variable "leader_tls_servername" {
  type        = string
  description = "The fqdn used to generate the certificate."
}

variable "vault_version" {
  type        = string
  description = "The version of the Vault binary to download."
  default     = "1.8.0"
}
resource "random_id" "id" {
  byte_length = 4
}

locals {
  resource_group_name = "vault-${random_id.id.hex}"

  vault_net_nsg = "vault-net-${random_id.id.hex}"

  vault_nic_nsg = "vault-nic-${random_id.id.hex}"

  vault_asg = "vault-asg-${random_id.id.hex}"

  vault_vm = "vault-${random_id.id.hex}"

  vault_user_id = "vault-userid-${random_id.id.hex}"

  pip_name = "vault-${random_id.id.hex}"

  key_vault_name = "vault-${random_id.id.hex}"

  nat_gateway_name = "vault-${random_id.id.hex}"

}