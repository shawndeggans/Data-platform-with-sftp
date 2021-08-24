param config object

// Configure the access policies in a seperate module or in the main 
// the only thing we need to set is the data factory two values
resource keyVaultResource 'Microsoft.KeyVault/vaults@2020-04-01-preview' = {
  name: config.keyVaultName
  location: config.location
  tags: config.tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: config.tenantId
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    enableRbacAuthorization: false
    accessPolicies: []
  }
}

output objectId string = keyVaultResource.id

