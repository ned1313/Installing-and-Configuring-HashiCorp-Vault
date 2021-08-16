variable "location" {
  type    = string
  default = "East US"
}

variable "aks_kubernetes_version" {
  type = string
  default = "1.20.7"
}

variable "node_count" {
  type = number
  default = 3
}

variable "node_size" {
  type = string
  default = "Standard_B2ms"
}
resource "random_id" "id" {
  byte_length = 4
}


locals {
  resource_group_name = "vault-${random_id.id.hex}"

  aks_cluster_name = "vault-${random_id.id.hex}"

  aks_dns_prefix = lower(local.aks_cluster_name)



}