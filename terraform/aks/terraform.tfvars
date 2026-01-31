# Terraform variables file for AKS
# Override default values as needed

resource_group_name = "rg-demo-aks"
location            = "eastus"
cluster_name        = "aks-demo"
dns_prefix          = "aksdemo"
kubernetes_version  = "1.28"
node_count          = 2
node_vm_size        = "Standard_D2s_v3"
node_pool_name      = "default"
enable_auto_scaling = true
min_node_count      = 1
max_node_count      = 5
network_plugin      = "azure"

tags = {
  environment = "demo"
  managed_by  = "terraform"
}
