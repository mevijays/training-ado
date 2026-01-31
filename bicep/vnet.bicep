// VNet resource - deploys at resource group scope
resource vnet 'Microsoft.Network/virtualNetworks@2024-03-01' = {
  name: 'demo-vnet'
  location: 'eastus'
  properties: {
    addressSpace: {
      addressPrefixes: [ '10.10.0.0/16' ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.10.1.0/24'
        }
      }
    ]
  }
}
