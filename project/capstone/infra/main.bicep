// Infra for the deploy targets: ACR + AKS + Log Analytics + App Insights.

targetScope = 'resourceGroup'

@allowed(['dev', 'stage', 'prod'])
param env string = 'dev'

@description('Region for all resources')
param location string = resourceGroup().location

param baseName string = 'blueleaf'

param tags object = {
  project: 'blueleaf'
  env: env
  managed_by: 'bicep'
  owner: 'platform-team'
}

resource acr 'Microsoft.ContainerRegistry/registries@2024-01-01-preview' = {
  name: '${baseName}acr'
  location: location
  tags: tags
  sku: { name: env == 'prod' ? 'Premium' : 'Basic' }
  properties: {
    adminUserEnabled: false
  }
}

resource law 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: 'law-${baseName}-${env}'
  location: location
  tags: tags
  properties: {
    sku: { name: 'PerGB2018' }
    retentionInDays: env == 'prod' ? 90 : 30
  }
}

resource appi 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appi-${baseName}-${env}'
  location: location
  tags: tags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: law.id
  }
}

resource aks 'Microsoft.ContainerService/managedClusters@2024-09-01' = {
  name: 'aks-${baseName}'
  location: location
  tags: tags
  identity: { type: 'SystemAssigned' }
  properties: {
    dnsPrefix: '${baseName}${env}'
    agentPoolProfiles: [
      {
        name: 'system'
        count: 1
        vmSize: env == 'prod' ? 'Standard_D2s_v5' : 'Standard_B2s'
        mode: 'System'
        osType: 'Linux'
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
    }
    addonProfiles: {
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: law.id
        }
      }
    }
  }
}

// Give AKS managed identity AcrPull on the registry
resource acrPull 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: acr
  name: guid(acr.id, aks.id, 'acrpull')
  properties: {
    principalType: 'ServicePrincipal'
    principalId: aks.identity.principalId
    roleDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/7f951dda-4ed3-4680-a7ca-43fe172d538d'
  }
}

output acrName string = acr.name
output aksName string = aks.name
output appInsightsConnectionString string = appi.properties.ConnectionString
