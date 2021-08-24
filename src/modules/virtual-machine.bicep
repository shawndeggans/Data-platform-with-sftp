param config object

resource bastionVent 'Microsoft.Network/virtualNetworks@2020-08-01' = {
  name: config.vnetName
  location: config.location
  tags: config.tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/24'
        '10.2.0.0/25'
      ]
    }
    dhcpOptions: {
      dnsServers: []
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.1.0.0/24'
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.2.0.0/25'
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}

//old Microsoft.Network/virtualNetworks/subnets@2020-11-01
resource bastionSubNet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' = {
  parent: bastionVent
  name: 'AzureBastionSubnet'
  properties: {
    addressPrefix: '10.2.0.0/25'
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

//old Microsoft.Network/virtualNetworks/subnets@2020-11-01
resource defaultSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-08-01' = {
  parent: bastionVent
  name: 'default'
  properties: {
    addressPrefix: '10.1.0.0/24'
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2020-05-01' = {
  name: config.networkInterfaceName
  location: config.location
  tags: config.tags
  properties: {
    ipConfigurations: [
      {
        name: 'internal'
        properties: {
          privateIPAddress: '10.1.0.4'
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: defaultSubnet.id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
  }
}


resource virtualMachines_vm_ir_dev_name_resource 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: config.integrationRuntimeName
  location: config.location
  tags: config.tags
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_F2'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2016-Datacenter'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        name: '${config.integrationRuntimeName}_OsDisk_1_0bb57282319840d1af8f1c511dfe7b8c'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        writeAcceleratorEnabled: false
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        diskSizeGB: 127
      }
      dataDisks: []
    }
    osProfile: {
      computerName: config.integrationRuntimeName
      adminUsername: 'IntegrationRuntime'
      adminPassword: config.integrationRuntimeVmAdministratorPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
        }
        winRM: {
          listeners: []
        }
      }
      secrets: []
      allowExtensionOperations: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
          properties: {
            primary: true
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
    priority: 'Regular'
  }
}

resource publicIPAddresses 'Microsoft.Network/publicIPAddresses@2020-08-01' = {
  name: config.publicIPAddressName
  location: config.location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}

resource bastionHostNameResource 'Microsoft.Network/bastionHosts@2020-08-01' = {
  name: config.bastionHostName
  location: config.location
  tags: config.tags
  properties: {
    ipConfigurations: [
      {
        name: 'configuration'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddresses.id
          }
          subnet: {
            id: bastionSubNet.id
          }
        }
      }
    ]
  }
}
