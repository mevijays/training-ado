# Terraform variables file
# Override default values as needed

resource_group_name     = "rg-demo-vm"
location                = "eastus"
vnet_name               = "vnet-demo"
vnet_address_space      = ["10.0.0.0/16"]
subnet_name             = "subnet-demo"
subnet_address_prefixes = ["10.0.1.0/24"]
vm_name                 = "vm-demo"
vm_size                 = "Standard_B2s"
admin_username          = "azureuser"
# admin_password should be provided via environment variable or pipeline secret

tags = {
  environment = "demo"
  managed_by  = "terraform"
}
