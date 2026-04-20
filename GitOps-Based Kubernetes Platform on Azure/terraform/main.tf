# create resource group
resource "azurerm_resource_group" "gitops_rg2345234" {
  name     = "gitops_rg2345234"
  location = "West Europe"
}

# create ACR
resource "azurerm_container_registry" "acr" {
  name                = "gitopscontainerregistry7677"
  resource_group_name = azurerm_resource_group.gitops_rg2345234.name
  location            = azurerm_resource_group.gitops_rg2345234.location
  sku                 = "Basic"
  admin_enabled       = false
}

# create AKS
resource "azurerm_kubernetes_cluster" "example" {
  name                = "example-aks1_test234"
  location            = azurerm_resource_group.gitops_rg2345234.location
  resource_group_name = azurerm_resource_group.gitops_rg2345234.name
  dns_prefix          = "exampleaks1"
  oidc_issuer_enabled = true 

  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = "Standard_B2ls_v2"
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }
  network_profile {
    network_plugin = "azure"
    dns_service_ip = "10.0.0.10"
    service_cidr   = "10.0.0.0/16"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}