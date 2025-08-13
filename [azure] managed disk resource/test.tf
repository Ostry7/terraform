terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.38.1"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "XXXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX" # Replace with your Azure subscription ID
}

data "azurerm_resource_group" "rg_lab" {
  name = "RG-TerraformLab"
}

resource "azurerm_managed_disk" "rg_lab_managed_disk" {
  name                 = "OSTR-managed-disk"
  location             = "East US"
  resource_group_name  = data.azurerm_resource_group.rg_lab.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1"
}