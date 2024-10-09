@description('The location into which the resources will be deployed')
param location string = resourceGroup().location

@description('Admin username for the virtual machine')
param adminUsername string

@secure()
@description('Admin password for the virtual machine')
param adminPassword string

@description('The name of the virtual machine')
param vmName string = 'myVM'

@description('The size of the virtual machine')
param vmSize string = 'Standard_B1ls'

@description('The name of the public IP')
param publicIPName string = 'myPublicIP'

@description('The name of the virtual network')
param vnetName string = 'myVnet'

@description('The name of the subnet')
param subnetName string = 'default'

@description('The address prefix for the virtual network')
param addressPrefix string = '10.0.0.0/16'

@description('The address prefix for the subnet')
param subnetPrefix string = '10.0.0.0/24'

@description('Network Security Group to allow HTTP and HTTPS access')
resource nsg 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: 'myNSG'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-HTTP'
        properties: {
          priority: 1001
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'Allow-HTTPS'
        properties: {
          priority: 1002
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

// Create a virtual network
resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [addressPrefix]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
        }
      }
    ]
  }
}

// Create a public IP address
resource publicIP 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: publicIPName
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

// Create a network interface card (NIC)
resource nic 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: '${vmName}Nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipConfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIP.id
          }
          subnet: {
            id: vnet.properties.subnets[0].id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

// Create a virtual machine
resource vm 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

// Output the public IP address
output vmPublicIP string = publicIP.properties.ipAddress
