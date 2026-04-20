# vnet aks
resource "azurerm_virtual_network" "vnet" {
  name                = "aks-vnet"
  location            = azurerm_resource_group.gitops_rg2345234.location
  resource_group_name = azurerm_resource_group.gitops_rg2345234.name
  address_space       = ["10.0.0.0/8"]
}

# subnet aks
resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.gitops_rg2345234.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.240.0.0/16"]

}