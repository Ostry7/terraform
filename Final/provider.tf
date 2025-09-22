terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.38.1"
    }
  }
  backend "azurerm" {
    resource_group_name  = "RG-TerraformLab"
    storage_account_name = "tfstate1701150913"
    container_name       = "xxxxtfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = "8610ce1e-59a0-4c91-91e6-07e58acd94b7" # Replace with your Azure subscription ID
}
