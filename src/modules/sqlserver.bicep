param config object

resource sqlServer 'Microsoft.Sql/servers@2019-06-01-preview' = {
  name: config.sqlServerName
  location: 'westus'
  tags: config.tags
  properties: {
    administratorLogin: config.sqlAdminUsername
    administratorLoginPassword : config.sqlAdminPassword
    version: '12.0'
  }
}
