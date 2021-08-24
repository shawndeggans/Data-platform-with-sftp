param config object

resource symbolicname 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: config.dataFactoryName
  location: config.location
  tags: config.tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    globalParameters: {}
  }
}
