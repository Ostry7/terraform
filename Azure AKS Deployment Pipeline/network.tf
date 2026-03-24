# vnet aks
resource "azurerm_virtual_network" "vnet" {
  name = "aks-vnet"
  location = azurerm_resource_group.infra_rg_123.location
  resource_group_name = azurerm_resource_group.infra_rg_123.name
  address_space = ["10.0.0.0/8"]
}

# subnet aks
resource "azurerm_subnet" "aks_subnet" {
  name = "aks-subnet"
  resource_group_name = azurerm_resource_group.infra_rg_123.name
  virtual_network_name = azurerm_virtual_network.vnet
  address_prefixes = ["10.240.0.0/16"]
  
}