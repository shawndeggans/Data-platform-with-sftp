@secure()
@description('The administrator login username for the SQL server.')
param sqlServerAdministratorLogin string

@secure()
@description('The administrator login password for the SQL server.')
param sqlServerAdministratorLoginPassword string

@secure()
@description('The administrator login password for the Integration Runtime Virtual Machine.')
param integrationRuntimeVmAdministratorPassword string

// is private network?
param environment string = 'stage'
param isPrivateNetworking bool = false
param integrationRuntimeName string = 'vm-ir-${environment}'
param integrationRuntimeDiscName string = 'vm-ir-disc-${uniqueString(resourceGroup().id)}'
param keyVaultName string = 'kv-mods-${uniqueString(resourceGroup().id)}'
param bastionHostName string = 'bast-mods-${uniqueString(resourceGroup().id)}'
param storageAccountAuditsName string = 'staudit${uniqueString(resourceGroup().id)}'
param vnetName string = 'vn-mods-${environment}${uniqueString(resourceGroup().id)}'
param sftpGroupName string = 'sftp-group'
param storageAccountSFTPName string = 'sftpst${uniqueString(resourceGroup().id)}'
param networkInterfaceName string = 'ni-mods-${uniqueString(resourceGroup().id)}'
param publicIPAddressName string = 'ip-mods-${uniqueString(resourceGroup().id)}'
param sqlServerName string = 'sql-mods-${uniqueString(resourceGroup().id)}'
param dataFactoryName string = 'adf-mods-${uniqueString(resourceGroup().id)}'

//Create a configurator object to hold the configuration
var config = {
  location: 'westus'
  isBYOVnet: isPrivateNetworking
  integrationRuntimeName: integrationRuntimeName
  integrationRuntimeDiscName: integrationRuntimeDiscName
  keyVaultName: keyVaultName
  bastionHostName: bastionHostName
  storageAccountAuditsName: storageAccountAuditsName
  vnetName: vnetName
  sftpGroupName: sftpGroupName
  storageAccountSFTPName: storageAccountSFTPName
  networkInterfaceName: networkInterfaceName
  publicIPAddressName: publicIPAddressName
  sqlAdminUsername: sqlServerAdministratorLogin
  sqlAdminPassword: sqlServerAdministratorLoginPassword
  sqlServerName: sqlServerName
  tenantId: '[PLACE TENANT ID HERE]'
  dataFactoryName: dataFactoryName
  tags: resourceGroup().tags
  integrationRuntimeVmAdministratorPassword: integrationRuntimeVmAdministratorPassword
}

module sqlServer 'modules/sqlserver.bicep' = {
  name: config.sqlServerName
  params: {
    config: config
  }
}

module dataFactory 'modules/dataFactory.bicep' = {
  name: config.dataFactoryName
  params: {
    config: config
  }
}

module keyVault 'modules/keyVault.bicep' = {
  name: config.keyVaultName
  params: {
    config: config
  }
}

module integrationRuntime 'modules/virtual-machine.bicep' = {
  name: config.integrationRuntimeName
  params: {
    config: config
  } 
}

//old Microsoft.Sql/servers/administrators@2021-02-01-preview
resource adAdmin 'Microsoft.Sql/servers/administrators@2019-06-01-preview' = {
  parent: sqlServer
  name: '${sqlServer.name}/ActiveDirectory'
  properties: {
    administratorType: 'ActiveDirectory'
    login: 'Mods-sqldbas-dev'
    sid: '[PLACE SID HERE]'
    tenantId: config.tenantId
  }
}

resource servers_sql_mods_dev4bd5b764_name_ForceLastGoodPlan 'Microsoft.Sql/servers/advisors@2014-04-01' = {
  parent: sqlServer
  name: '${sqlServer.name}/ForceLastGoodPlan'
  properties: {
    autoExecuteValue: 'Enabled'
  }
}

//old Microsoft.Sql/servers/databases@2021-02-01-preview
resource careLogicDatabase 'Microsoft.Sql/servers/databases@2020-08-01-preview' = {
  parent: sqlServer
  name: '${sqlServer.name}/MODS-SQL-CF-CareLogic'
  location: config.location
  sku: {
    name: 'GP_S_Gen5'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    capacity: 4
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 536870912000
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: false
    readScale: 'Disabled'
    autoPauseDelay: 60
    minCapacity: 1
    maintenanceConfigurationId: '/subscriptions/[PLACE SUBSCRIPTION HERE]/providers/Microsoft.Maintenance/publicMaintenanceConfigurations/SQL_Default'
  }
}

//old Microsoft.Sql/servers/databases@2021-02-01-preview
resource fileMakerProDatabase 'Microsoft.Sql/servers/databases@2020-08-01-preview' = {
  parent: sqlServer
  name: '${sqlServer.name}/MODS-SQL-CF-FileMaker'
  location: 'westus'
  sku: {
    name: 'GP_S_Gen5'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    capacity: 4
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 34359738368
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: false
    readScale: 'Disabled'
    autoPauseDelay: 60
    minCapacity: 1
  }
}

module containerGroup 'modules/sftp-container.bicep' = {
  name: config.sftpGroupName
  params: {
    config: config
  }
}


