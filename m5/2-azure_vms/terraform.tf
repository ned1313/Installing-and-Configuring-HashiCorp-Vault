# This configuration spins up three Azure VMs that will form
# the Vault cluster. The virtual machines will be placed behind
# a public facing load balancer to expose the UI and API port

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.38.0"
    }
  }
}

provider "azurerm" {
  #skip_provider_registration = "true"
  features {}
}



# Used to get tenant ID as needed
data "azurerm_client_config" "current" {}
data "azuread_client_config" "current" {}