targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment (e.g., dev, staging, prod)')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string = 'westus3'

@description('Name of the App Service Plan')
param appServicePlanName string = ''

@description('Name of the Web App')
param webAppName string = ''

@description('Name of the Container Registry')
param containerRegistryName string = ''

@description('Name of the Log Analytics Workspace')
param logAnalyticsName string = ''

@description('Name of the Application Insights instance')
param applicationInsightsName string = ''

@description('Name of the AI Foundry Hub')
param aiHubName string = ''

@description('Name of the AI Foundry Project')
param aiProjectName string = ''

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = { 'azd-env-name': environmentName }

// Resource Group
resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${environmentName}'
  location: location
  tags: tags
}

// Log Analytics + Application Insights
module monitoring './modules/monitoring.bicep' = {
  name: 'monitoring'
  scope: rg
  params: {
    location: location
    tags: tags
    logAnalyticsName: !empty(logAnalyticsName) ? logAnalyticsName : '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
    applicationInsightsName: !empty(applicationInsightsName) ? applicationInsightsName : '${abbrs.insightsComponents}${resourceToken}'
  }
}

// Container Registry
module containerRegistry './modules/container-registry.bicep' = {
  name: 'container-registry'
  scope: rg
  params: {
    location: location
    tags: tags
    name: !empty(containerRegistryName) ? containerRegistryName : '${abbrs.containerRegistryRegistries}${resourceToken}'
  }
}

// App Service (Linux + Docker)
module appService './modules/app-service.bicep' = {
  name: 'app-service'
  scope: rg
  params: {
    location: location
    tags: tags
    appServicePlanName: !empty(appServicePlanName) ? appServicePlanName : '${abbrs.webServerFarms}${resourceToken}'
    webAppName: !empty(webAppName) ? webAppName : '${abbrs.webSitesAppService}${resourceToken}'
    applicationInsightsConnectionString: monitoring.outputs.applicationInsightsConnectionString
    containerRegistryLoginServer: containerRegistry.outputs.loginServer
  }
}

// Role Assignment: App Service -> ACR Pull
module acrPullRole './modules/acr-pull-role.bicep' = {
  name: 'acr-pull-role'
  scope: rg
  params: {
    containerRegistryName: containerRegistry.outputs.name
    principalId: appService.outputs.identityPrincipalId
  }
}

// Azure AI Foundry (Hub + Project + Model Deployments)
module aiFoundry './modules/ai-foundry.bicep' = {
  name: 'ai-foundry'
  scope: rg
  params: {
    location: location
    tags: tags
    hubName: !empty(aiHubName) ? aiHubName : '${abbrs.aiHub}${resourceToken}'
    projectName: !empty(aiProjectName) ? aiProjectName : '${abbrs.aiProject}${resourceToken}'
    logAnalyticsWorkspaceId: monitoring.outputs.logAnalyticsWorkspaceId
    applicationInsightsId: monitoring.outputs.applicationInsightsId
  }
}

// Outputs
output AZURE_LOCATION string = location
output AZURE_RESOURCE_GROUP string = rg.name
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = containerRegistry.outputs.loginServer
output AZURE_CONTAINER_REGISTRY_NAME string = containerRegistry.outputs.name
output WEB_APP_NAME string = appService.outputs.name
output WEB_APP_URL string = appService.outputs.url
output APPLICATIONINSIGHTS_CONNECTION_STRING string = monitoring.outputs.applicationInsightsConnectionString
output AI_FOUNDRY_HUB_NAME string = aiFoundry.outputs.hubName
output AI_FOUNDRY_PROJECT_NAME string = aiFoundry.outputs.projectName
