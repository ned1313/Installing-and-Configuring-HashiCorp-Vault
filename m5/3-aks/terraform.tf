# This configuration spins up an AKS cluster with a single node pool
# composed of three nodes. The deployment creates a standalone Vnet
# and uses the default networking options.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Used to get tenant ID as needed
data "azurerm_client_config" "current" {}