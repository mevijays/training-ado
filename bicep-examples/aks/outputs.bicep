// Azure AKS Resources - Outputs Module
// This module deploys AKS resources and outputs the results

// Parameters
param location string
param clusterName string
param dnsPrefix string
param kubernetesVersion string
param nodeCount int
param nodeVmSize string
param enableAutoScaling bool
param minNodeCount int
param maxNodeCount int
param networkPlugin string
param tags object

// AKS Cluster
resource aks 'Microsoft.ContainerService/managedClusters@2023-10-01' = {
  name: clusterName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: dnsPrefix
    kubernetesVersion: kubernetesVersion
    agentPoolProfiles: [
      {
        name: 'default'
        count: enableAutoScaling ? null : nodeCount
        vmSize: nodeVmSize
        mode: 'System'
        osType: 'Linux'
        osDiskSizeGB: 30
        type: 'VirtualMachineScaleSets'
        enableAutoScaling: enableAutoScaling
        minCount: enableAutoScaling ? minNodeCount : null
        maxCount: enableAutoScaling ? maxNodeCount : null
      }
    ]
    networkProfile: {
      networkPlugin: networkPlugin
      loadBalancerSku: 'standard'
    }
  }
}

// Outputs
output clusterId string = aks.id
output clusterName string = aks.name
output clusterFqdn string = aks.properties.fqdn
output nodeResourceGroup string = aks.properties.nodeResourceGroup
output identityPrincipalId string = aks.identity.principalId
