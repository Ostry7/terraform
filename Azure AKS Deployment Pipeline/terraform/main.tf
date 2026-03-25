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

# create AKS
resource "azurerm_kubernetes_cluster" "example" {
  name                = "example-aks1-test123"
  location            = azurerm_resource_group.infra_rg_123.location
  resource_group_name = azurerm_resource_group.infra_rg_123.name
  dns_prefix          = "exampleaks1"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2ls_v2"
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  network_profile {
    network_plugin = "azure"
    dns_service_ip = "10.0.0.10"
    service_cidr = "10.0.0.0/16"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.example.kube_config[0].client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.example.kube_config_raw

  sensitive = true
}