# create resource group for DR site
resource "azurerm_resource_group" "gitops_rg2345234_dr" {
  name     = "gitops_rg2345234_dr"
  location = "polandcentral"
}

# DR VNet
resource "azurerm_virtual_network" "dr_vnet" {
  name                = "dr-vnet"
  location            = azurerm_resource_group.gitops_rg2345234_dr.location
  resource_group_name = azurerm_resource_group.gitops_rg2345234_dr.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "dr_aks_subnet" {
  name                 = "dr-aks-subnet"
  resource_group_name  = azurerm_resource_group.gitops_rg2345234_dr.name
  virtual_network_name = azurerm_virtual_network.dr_vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

# create AKS
resource "azurerm_kubernetes_cluster" "dr" {
  name                = "aks-dr-234623465"
  location            = azurerm_resource_group.gitops_rg2345234_dr.location
  resource_group_name = azurerm_resource_group.gitops_rg2345234_dr.name
  dns_prefix          = "aksdr"
  oidc_issuer_enabled = true

  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = "Standard_B2ls_v2"
    vnet_subnet_id = azurerm_subnet.dr_aks_subnet.id
  }

  network_profile {
    network_plugin = "azure"
    dns_service_ip = "10.2.0.10"
    service_cidr   = "10.2.0.0/16"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "DR"
  }
}

resource "azurerm_role_assignment" "dr_wal" {
  principal_id                     = azurerm_kubernetes_cluster.dr.kubelet_identity[0].object_id
  role_definition_name             = "Storage Blob Data Reader"
  scope                            = azurerm_storage_account.wal.id
  skip_service_principal_aad_check = true
}

output "dr_aks_name" {
  value = azurerm_kubernetes_cluster.dr.name
}

output "dr_resource_group" {
  value = azurerm_resource_group.gitops_rg2345234_dr.name
}

# DR -> PROD Peering
resource "azurerm_virtual_network_peering" "peering_dr" {
  name                      = "peer_dr_prod"
  resource_group_name       = azurerm_resource_group.gitops_rg2345234_dr.name
  virtual_network_name      = azurerm_virtual_network.dr_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.vnet.id
}
