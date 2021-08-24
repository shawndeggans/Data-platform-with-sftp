param config object

resource containerGroupOld 'Microsoft.ContainerInstance/containerGroups@2020-11-01' = {
  name: config.sftpGroupName
  location: config.location
  tags: config.tags
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
    restartPolicy: 'OnFailure'
    ipAddress: {
      ports: [
        {
          protocol: 'TCP'
          port: 22
        }
      ]
      type: 'Public'
    }
    osType: 'Linux'
    volumes: [
      {
        name: 'sftpvolume'
        azureFile: {
          shareName: 'sftpfileshare'
          readOnly: false
          storageAccountName: config.storageAccountSFTPName
        }
      }
    ]
  }
}
