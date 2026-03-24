#create resource group
resource "azurerm_resource_group" "infra_rg_123" {
  name     = "infra_rg_123"
  location = "West Europe"
}