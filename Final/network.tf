resource "azurerm_virtual_network" "my_vnet" {
  name                = "${local.name_prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.rg_lab.location
  resource_group_name = data.azurerm_resource_group.rg_lab.name

}
resource "azurerm_subnet" "my_subnets" {
  for_each = var.subnets
  name                 = each.value.name
  resource_group_name  = data.azurerm_resource_group.rg_lab.name
  virtual_network_name = azurerm_virtual_network.my_vnet.name
  address_prefixes     = each.value.address_prefixes
}


resource "azurerm_network_interface" "my_nic" {
  count = var.number_vm
  name                = "${local.name_prefix}-${format("%02s", count.index + 1)}-nic"
  location            = data.azurerm_resource_group.rg_lab.location
  resource_group_name = data.azurerm_resource_group.rg_lab.name

  ip_configuration {
    name                          = "internal-dev"
    subnet_id                     = azurerm_subnet.my_subnets["tst"].id
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_managed_disk" "vm_data_disk" {
  count                = var.number_vm
  name                 = "${var.appcode}-${var.environment}-${format("%02s", count.index+1)}-datadisk"
  location             = data.azurerm_resource_group.rg_lab.location
  resource_group_name  = data.azurerm_resource_group.rg_lab.name
  storage_account_type = "Standard_LRS"
  disk_size_gb         = 1
  create_option        = "Empty"
}

resource "azurerm_virtual_machine_data_disk_attachment" "attachment_managed_disks" {
  count              = var.number_vm
  managed_disk_id    = azurerm_managed_disk.vm_data_disk[count.index].id
  virtual_machine_id = azurerm_virtual_machine.main[count.index].id
  lun                = count.index
  caching            = "ReadWrite"
}