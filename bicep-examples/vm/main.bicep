// Azure VM Deployment - Main Bicep Template
targetScope = 'subscription'

// Parameters
@description('Name of the resource group')
param resourceGroupName string = 'rg-demo-vm'

@description('Azure region for resources')
param location string = 'eastus'

@description('Name of the virtual network')
param vnetName string = 'vnet-demo'

@description('Address prefix for the virtual network')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('Name of the subnet')
param subnetName string = 'subnet-demo'

@description('Address prefix for the subnet')
param subnetAddressPrefix string = '10.0.1.0/24'

@description('Name of the virtual machine')
param vmName string = 'vm-demo'

@description('Size of the virtual machine')
param vmSize string = 'Standard_B2s'

@description('Admin username for the VM')
param adminUsername string = 'azureuser'

@description('Admin password for the VM')
@secure()
param adminPassword string

@description('Tags to apply to resources')
param tags object = {
  environment: 'demo'
  managed_by: 'bicep'
}

// Resource Group
resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

// Module for VM resources
module vmResources 'outputs.bicep' = {
  name: 'vmDeployment'
  scope: rg
  params: {
    location: location
    vnetName: vnetName
    vnetAddressPrefix: vnetAddressPrefix
    subnetName: subnetName
    subnetAddressPrefix: subnetAddressPrefix
    vmName: vmName
    vmSize: vmSize
    adminUsername: adminUsername
    adminPassword: adminPassword
    tags: tags
  }
}

// Outputs
output resourceGroupName string = rg.name
output resourceGroupId string = rg.id
output vmPublicIp string = vmResources.outputs.publicIpAddress
output vmPrivateIp string = vmResources.outputs.privateIpAddress
