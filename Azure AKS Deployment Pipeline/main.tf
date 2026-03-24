# create resource group
resource "azurerm_resource_group" "infra_rg_123" {
  name     = "infra_rg_123"
  location = "West Europe"
}

# create ACR
resource "azurerm_container_registry" "acr" {
  name                = "acrapp01"
  resource_group_name = azurerm_resource_group.infra_rg_123.name
  location            = azurerm_resource_group.infra_rg_123.location
  sku                 = "Basic"
  admin_enabled       = false
}

