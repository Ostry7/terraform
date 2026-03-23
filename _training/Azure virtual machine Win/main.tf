resource "azurerm_virtual_network" "app_vnet" {
  name                = "ostr-APP-VNET"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.rg_lab.location
  resource_group_name = data.azurerm_resource_group.rg_lab.name
}

resource "azurerm_subnet" "dev_subnet" {
  name                 = "ostr-dev-subnet"
  resource_group_name  = data.azurerm_resource_group.rg_lab.name
  virtual_network_name = azurerm_virtual_network.app_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "tst_subnet" {
  name                 = "ostr-tst-subnet"
  resource_group_name  = data.azurerm_resource_group.rg_lab.name
  virtual_network_name = azurerm_virtual_network.app_vnet.name
  address_prefixes     = ["10.0.3.0/24"]
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


resource "azurerm_virtual_machine" "main" {
  name                  = "OSTR-app01vm"
  location              = data.azurerm_resource_group.rg_lab.location
  resource_group_name   = data.azurerm_resource_group.rg_lab.name
  network_interface_ids = [azurerm_network_interface.dev_nic.id, azurerm_network_interface.tst_nic.id]
  vm_size               = "Standard_B2s"
  primary_network_interface_id = azurerm_network_interface.dev_nic.id 

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
    os_profile {
    computer_name  = "OSTR-app01vm"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_windows_config { 
    provision_vm_agent = true
}
}