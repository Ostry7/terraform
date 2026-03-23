variable "subnets" {
  type = map(any)
  default = {
    "bastion" = {
      name             = "AzureBastionSubnet"
      address_prefixes = ["10.0.1.0/24"]
    },
    "dev" = {
      name             = "ostr-dev-subnet"
      address_prefixes = ["10.0.2.0/24"]
    },
    "tst" = {
      name             = "ostr-tst-subnet"
      address_prefixes = ["10.0.3.0/24"]
    },
    "app" = {
      name             = "ostr-app-subnet"
      address_prefixes = ["10.0.4.0/24"]
    }
  }
}
variable "number_vm" {
    default = 1
}

variable "appcode" {
  default = "OSTR"
}

variable "environment" {
  default = "dev"
}

variable "vm_size" {
  default = "Standard_B2s"
}

variable "storage_image_reference" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2022-Datacenter"
      version   = "latest"
  }
}

variable "storage_os_disk" {
  type = object({
    name              = string
    caching           = string
    create_option     = string
    managed_disk_type = string
  })
  default = {
    name              = "ostr_osdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
}

variable "user_config" {
  type = object({
    username      = string
    user_password = string
  })
  default = {
    username      = "testadmin"
    user_password = "Password1234!"
  }
}

variable "managed_disk_entity" {
  type = map(any)
  default = {
    "prod_disk" = {
      name                 = "ostr-prod-disk"
      disk_size_gb         = 1
      storage_account_type = "Standard_LRS"
      create_option        = "Empty"
    },
    "tst_disk" = {
      name                 = "ostr-tst-disk"
      disk_size_gb         = 1
      storage_account_type = "Standard_LRS"
      create_option        = "Empty"
    },
    "dev_disk" = {
      name                 = "ostr-dev-disk"
      disk_size_gb         = 1
      storage_account_type = "Standard_LRS"
      create_option        = "Empty"
    }
  }
}

variable "ssh_public_key" {
  description = "Public SSH key to use for all VMs"
  type        = string
}
