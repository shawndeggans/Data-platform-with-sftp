param config object

resource storageAccounts_sftpstgeew6ui3gwwgnu_name_resource 'Microsoft.Storage/storageAccounts@2021-01-01' = {
  name: config.storageAccountSFTPName
  location: config.location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: false
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    largeFileSharesState: 'Enabled'
  }
}

resource storageAccounts_sftpstgeew6ui3gwwgnu_name_default 'Microsoft.Storage/storageAccounts/blobServices@2021-01-01' = {
  parent: storageAccounts_sftpstgeew6ui3gwwgnu_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: [
        {
          allowedOrigins: [
            '*'
          ]
          allowedMethods: [
            'PUT'
          ]
          maxAgeInSeconds: 30
          exposedHeaders: [
            '*'
          ]
          allowedHeaders: [
            '*'
          ]
        }
      ]
    }
    deleteRetentionPolicy: {
      enabled: false
    }
  }
}

resource Microsoft_Storage_storageAccounts_fileServices_storageAccounts_sftpstgeew6ui3gwwgnu_name_default 'Microsoft.Storage/storageAccounts/fileServices@2021-01-01' = {
  parent: storageAccounts_sftpstgeew6ui3gwwgnu_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: [
        {
          allowedOrigins: [
            '*'
          ]
          allowedMethods: [
            'PUT'
          ]
          maxAgeInSeconds: 30
          exposedHeaders: [
            '*'
          ]
          allowedHeaders: [
            '*'
          ]
        }
      ]
    }
  }
}

resource Microsoft_Storage_storageAccounts_queueServices_storageAccounts_sftpstgeew6ui3gwwgnu_name_default 'Microsoft.Storage/storageAccounts/queueServices@2021-01-01' = {
  parent: storageAccounts_sftpstgeew6ui3gwwgnu_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: [
        {
          allowedOrigins: [
            '*'
          ]
          allowedMethods: [
            'PUT'
          ]
          maxAgeInSeconds: 30
          exposedHeaders: [
            '*'
          ]
          allowedHeaders: [
            '*'
          ]
        }
      ]
    }
  }
}

resource Microsoft_Storage_storageAccounts_tableServices_storageAccounts_sftpstgeew6ui3gwwgnu_name_default 'Microsoft.Storage/storageAccounts/tableServices@2021-01-01' = {
  parent: storageAccounts_sftpstgeew6ui3gwwgnu_name_resource
  name: 'default'
  properties: {
    cors: {
      corsRules: [
        {
          allowedOrigins: [
            '*'
          ]
          allowedMethods: [
            'PUT'
          ]
          maxAgeInSeconds: 30
          exposedHeaders: [
            '*'
          ]
          allowedHeaders: [
            '*'
          ]
        }
      ]
    }
  }
}

resource storageAccounts_sftpstgeew6ui3gwwgnu_name_default_sftpfileshare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-01-01' = {
  parent: Microsoft_Storage_storageAccounts_fileServices_storageAccounts_sftpstgeew6ui3gwwgnu_name_default
  name: 'sftpfileshare'
  properties: {
    accessTier: 'TransactionOptimized'
    shareQuota: 5120
    enabledProtocols: 'SMB'
  }
  dependsOn: [
    storageAccounts_sftpstgeew6ui3gwwgnu_name_resource
  ]
}

// This Bicep variable is not compiled into an ARM template variable,
// but instead expression is inserted in every place where it's used.
var keysObj = listKeys(resourceId('Microsoft.Storage/storageAccounts', storageAccounts_sftpstgeew6ui3gwwgnu_name_resource.name), '2021-02-01')

resource containerGroups_sftp_group_name_resource 'Microsoft.ContainerInstance/containerGroups@2021-03-01' = {
  name: config.sftpGroupName
  location: config.location
  properties: {
    sku: 'Standard'
    containers: [
      {
        name: 'sftp'
        properties: {
          image: 'atmoz/sftp:latest'
          ports: [
            {
              port: 22
            }
          ]
          environmentVariables: [
            {
              name: 'SFTP_USERS'
              value: 'sftpuser:N)Sb7V87v(hj-ar+:1001'
            }
          ]
          resources: {
            requests: {
              memoryInGB: 1
              cpu: 2
            }
          }
          volumeMounts: [
            {
              name: 'sftpvolume'
              mountPath: '/home/sftpuser/upload'
              readOnly: false
            }
          ]
        }
      }
    ]
    initContainers: []
    restartPolicy: 'OnFailure'
    ipAddress: {
      ports: [
        {
          protocol: 'TCP'
          port: 22
        }
      ]
      type: 'Public'
      dnsNameLabel: 'flb5uloxbkygm'
    }
    osType: 'Linux'
    volumes: [
      {
        name: 'sftpvolume'
        azureFile: {
          shareName: 'sftpfileshare'
          readOnly: false
          storageAccountName: config.storageAccountSFTPName
          storageAccountKey: keysObj.keys[0].value
        }
      }
    ]
  }
  dependsOn: [
    storageAccounts_sftpstgeew6ui3gwwgnu_name_default
    storageAccounts_sftpstgeew6ui3gwwgnu_name_default_sftpfileshare
  ]
}
