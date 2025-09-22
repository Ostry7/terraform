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
  subscription_id = "XXXXXXXXXXXXXXXXXXXXXXXX" # Replace with your Azure subscription ID
}
