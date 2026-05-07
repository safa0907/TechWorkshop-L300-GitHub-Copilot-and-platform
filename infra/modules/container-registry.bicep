@description('Location for all resources')
param location string

@description('Tags for all resources')
param tags object

@description('Name of the Container Registry')
param name string

// Azure Container Registry - Standard tier, admin disabled (RBAC only)
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    adminUserEnabled: false
  }
}

output loginServer string = containerRegistry.properties.loginServer
output name string = containerRegistry.name
output id string = containerRegistry.id
