// Subscription-level deployment to create resource group and resources
targetScope = 'subscription'

// Create resource group
resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: 'demo-rg'
  location: 'eastus'
}

// Deploy VNet module into the resource group
module vnetDeploy 'vnet.bicep' = {
  name: 'vnetDeployment'
  scope: rg
}
