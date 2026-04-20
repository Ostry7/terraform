# create resource group
resource "azurerm_resource_group" "gitops_rg2345234" {
  name     = "gitops_rg2345234"
  location = "West Europe"
}

# create ACR
resource "azurerm_container_registry" "acr" {
  name                = "containerRegistry1"
  resource_group_name = azurerm_resource_group.gitops_rg2345234.name
  location            = azurerm_resource_group.gitops_rg2345234.location
  sku                 = "Basic"
  admin_enabled       = false
}