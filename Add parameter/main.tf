resource "azurerm_virtual_machine" "main" {
  name                         = var.vm_name
  location                     = data.azurerm_resource_group.rg_lab.location
  resource_group_name          = data.azurerm_resource_group.rg_lab.name
  network_interface_ids        = [azurerm_network_interface.dev_nic.id, azurerm_network_interface.tst_nic.id]
  vm_size                      = var.vm_size
  primary_network_interface_id = azurerm_network_interface.dev_nic.id

  storage_image_reference {
    publisher = var.storage_image_reference.publisher
    offer     = var.storage_image_reference.offer
    sku       = var.storage_image_reference.sku
    version   = var.storage_image_reference.version
  }
  storage_os_disk {
    name              = var.storage_os_disk.name
    caching           = var.storage_os_disk.caching
    create_option     = var.storage_os_disk.create_option
    managed_disk_type = var.storage_os_disk.managed_disk_type
  }
  os_profile {
    computer_name  = var.vm_name
    admin_username = var.user_config.username
    admin_password = var.user_config.user_password
  }
  os_profile_windows_config {
    provision_vm_agent = true
  }



}