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
  subscription_id = "XXXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX" # Replace with your Azure subscription ID
}
