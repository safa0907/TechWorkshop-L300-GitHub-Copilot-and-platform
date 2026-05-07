@description('Location for all resources')
param location string

@description('Tags for all resources')
param tags object

@description('Name of the AI Foundry Hub')
param hubName string

@description('Name of the AI Foundry Project')
param projectName string

@description('Log Analytics Workspace ID for diagnostics')
param logAnalyticsWorkspaceId string

@description('Application Insights resource ID')
param applicationInsightsId string

// Storage Account required by AI Hub
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'st${uniqueString(resourceGroup().id, hubName)}'
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
  }
}

// Key Vault required by AI Hub
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: 'kv-${uniqueString(resourceGroup().id, hubName)}'
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
  }
}

// Azure AI Services (Cognitive Services) for model hosting
resource aiServices 'Microsoft.CognitiveServices/accounts@2024-04-01-preview' = {
  name: 'ais-${uniqueString(resourceGroup().id, hubName)}'
  location: location
  tags: tags
  kind: 'AIServices'
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: 'ais-${uniqueString(resourceGroup().id, hubName)}'
    publicNetworkAccess: 'Enabled'
  }
}

// Azure AI Foundry Hub
resource aiHub 'Microsoft.MachineLearningServices/workspaces@2024-04-01' = {
  name: hubName
  location: location
  tags: tags
  kind: 'Hub'
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  properties: {
    friendlyName: hubName
    storageAccount: storageAccount.id
    keyVault: keyVault.id
    applicationInsights: applicationInsightsId
  }
}

// AI Services connection on the Hub
resource aiServicesConnection 'Microsoft.MachineLearningServices/workspaces/connections@2024-04-01' = {
  parent: aiHub
  name: 'ai-services-connection'
  properties: {
    category: 'AIServices'
    authType: 'AAD'
    target: aiServices.properties.endpoint
    metadata: {
      ApiType: 'Azure'
      ResourceId: aiServices.id
    }
  }
}

// Azure AI Foundry Project
resource aiProject 'Microsoft.MachineLearningServices/workspaces@2024-04-01' = {
  name: projectName
  location: location
  tags: tags
  kind: 'Project'
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  properties: {
    friendlyName: projectName
    hubResourceId: aiHub.id
  }
}

// GPT-4o Model Deployment
resource gpt4oDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-04-01-preview' = {
  parent: aiServices
  name: 'gpt-4o'
  sku: {
    name: 'Standard'
    capacity: 10
  }
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4o'
      version: '2024-11-20'
    }
  }
}

// Phi-4 Model Deployment
resource phiDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-04-01-preview' = {
  parent: aiServices
  name: 'Phi-4'
  dependsOn: [gpt4oDeployment]
  sku: {
    name: 'GlobalStandard'
    capacity: 1
  }
  properties: {
    model: {
      format: 'Microsoft'
      name: 'Phi-4'
      version: '7'
    }
  }
}

output hubName string = aiHub.name
output projectName string = aiProject.name
output aiServicesEndpoint string = aiServices.properties.endpoint
