terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.65.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstate34563456"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }

}


provider "azurerm" {
  # Configuration options
  features {}
  subscription_id = var.subscription_id
}