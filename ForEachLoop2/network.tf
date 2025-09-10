resource "azurerm_virtual_network" "app_vnet" {
  name                = var.subnets["app"].name
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.rg_lab.location
  resource_group_name = data.azurerm_resource_group.rg_lab.name
}

resource "azurerm_subnet" "dev_subnet" {
  name                 = var.subnets["dev"].name
  resource_group_name  = data.azurerm_resource_group.rg_lab.name
  virtual_network_name = azurerm_virtual_network.app_vnet.name
  address_prefixes     = var.subnets["dev"].address_prefixes
}

resource "azurerm_subnet" "tst_subnet" {
  name                 = var.subnets["tst"].name
  resource_group_name  = data.azurerm_resource_group.rg_lab.name
  virtual_network_name = azurerm_virtual_network.app_vnet.name
  address_prefixes     = var.subnets["tst"].address_prefixes
}

resource "azurerm_network_interface" "dev_nic" {
  name                = "ostr-dev-nic"
  location            = data.azurerm_resource_group.rg_lab.location
  resource_group_name = data.azurerm_resource_group.rg_lab.name

  ip_configuration {
    name                          = "internal-dev"
    subnet_id                     = azurerm_subnet.dev_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "tst_nic" {
  name                = "ostr-tst-nic"
  location            = data.azurerm_resource_group.rg_lab.location
  resource_group_name = data.azurerm_resource_group.rg_lab.name

  ip_configuration {
    name                          = "internal-tst"
    subnet_id                     = azurerm_subnet.tst_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_managed_disk" "loop_managed_disk" {
  for_each             = var.managed_disk_entity
  name                 = each.value.name
  location             = data.azurerm_resource_group.rg_lab.location
  resource_group_name  = data.azurerm_resource_group.rg_lab.name
  storage_account_type = each.value.storage_account_type
  disk_size_gb         = each.value.disk_size_gb
  create_option        = each.value.create_option
}

resource "azurerm_virtual_machine_data_disk_attachment" "attachment_managed_disks" {
  for_each = azurerm_managed_disk.loop_managed_disk
  managed_disk_id = each.value.id
  virtual_machine_id = azurerm_virtual_machine.main.id
  lun = index(keys(azurerm_managed_disk.loop_managed_disk), each.key)
  caching = "ReadWrite"
  
}