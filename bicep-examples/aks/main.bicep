// Azure AKS Deployment - Main Bicep Template
targetScope = 'subscription'

// Parameters
@description('Name of the resource group')
param resourceGroupName string = 'rg-demo-aks'

@description('Azure region for resources')
param location string = 'eastus'

@description('Name of the AKS cluster')
param clusterName string = 'aks-demo'

@description('DNS prefix for the AKS cluster')
param dnsPrefix string = 'aksdemo'

@description('Kubernetes version')
param kubernetesVersion string = '1.28'

@description('Number of nodes in the default node pool')
param nodeCount int = 2

@description('VM size for the default node pool')
param nodeVmSize string = 'Standard_D2s_v3'

@description('Enable auto scaling for the default node pool')
param enableAutoScaling bool = true

@description('Minimum number of nodes when auto scaling is enabled')
param minNodeCount int = 1

@description('Maximum number of nodes when auto scaling is enabled')
param maxNodeCount int = 5

@description('Network plugin (azure or kubenet)')
param networkPlugin string = 'azure'

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

// Module for AKS resources
module aksResources 'outputs.bicep' = {
  name: 'aksDeployment'
  scope: rg
  params: {
    location: location
    clusterName: clusterName
    dnsPrefix: dnsPrefix
    kubernetesVersion: kubernetesVersion
    nodeCount: nodeCount
    nodeVmSize: nodeVmSize
    enableAutoScaling: enableAutoScaling
    minNodeCount: minNodeCount
    maxNodeCount: maxNodeCount
    networkPlugin: networkPlugin
    tags: tags
  }
}

// Outputs
output resourceGroupName string = rg.name
output resourceGroupId string = rg.id
output clusterName string = aksResources.outputs.clusterName
output clusterId string = aksResources.outputs.clusterId
output clusterFqdn string = aksResources.outputs.clusterFqdn
