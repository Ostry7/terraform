resource "azurerm_virtual_network" "my_vnet" {
  name                = "ostr-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.rg_lab.location
  resource_group_name = data.azurerm_resource_group.rg_lab.name
}

resource "azurerm_subnet" "my_subnet" {
  name                 = "ostr-dev-subnet"
  resource_group_name  = data.azurerm_resource_group.rg_lab.name
  virtual_network_name = azurerm_virtual_network.my_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "example" {
  name                = "ostr-dev-nic"
  location            = data.azurerm_resource_group.rg_lab.location
  resource_group_name = data.azurerm_resource_group.rg_lab.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.my_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "my_vm" {
  name                = "ostr-vm"
  resource_group_name = data.azurerm_resource_group.rg_lab.name
  location            = data.azurerm_resource_group.rg_lab.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_virtual_network.my_vnet.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("./.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}