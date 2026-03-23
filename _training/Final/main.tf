module "vms" {
  source                  = "./virtual_machine_module"
  number_vm               = var.number_vm
  appcode                 = var.appcode
  environment             = var.environment
  vm_size                 = var.vm_size
  storage_image_reference = var.storage_image_reference
  storage_os_disk         = var.storage_os_disk
user_config = {
  username      = var.user_config.username
  user_password = var.user_config.user_password
}

  ssh_public_key = file("C:\\Users\\MarekOstrowski\\OneDrive - kyndryl\\Documents\\!!!GitRepo\\Terraform\\Final\\.ssh\\id_rsa.pub")
}

