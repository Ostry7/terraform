terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.38.1"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "8610ce1e-59a0-4c91-91e6-07e58acd94b7" # Replace with your Azure subscription ID
}
