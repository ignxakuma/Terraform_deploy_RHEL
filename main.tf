terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.52.0"
    }
  }
}

locals {
  tags= {
    Env = "Dev"
  }
}

provider "azurerm" {
  features {}
}
variable "bundle_name" {
   type = string
}

variable "env_name" {
  type = string
}

resource "azurerm_resource_group" "Terrarg" {
    name = "terrarg"
    location = "east us"  
    tags = {
      "Env" = "Dev"
    }
}

resource "azurerm_storage_account" "Terrastorage171998" {
    name = "terrastorage171998"
    resource_group_name = azurerm_resource_group.Terrarg.name
    location = azurerm_resource_group.Terrarg.location
    account_tier = "Standard"
    account_replication_type = "LRS"
    tags = {
      "Env" = "Dev"
    }
    account_kind = "StorageV2"
}

resource "azurerm_virtual_network" "terravnet" {
  name                = "terravnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.Terrarg.location
  resource_group_name = azurerm_resource_group.Terrarg.name
  tags = local.tags
}

resource "azurerm_subnet" "terrasubnet" {
  name                 = "Appsrvers"
  resource_group_name  = azurerm_resource_group.Terrarg.name
  virtual_network_name = azurerm_virtual_network.terravnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "terra-pub-ip" {
  name                = "terra-pub-ip"
  resource_group_name = azurerm_resource_group.Terrarg.name
  location            = azurerm_resource_group.Terrarg.location
  allocation_method   = "Static"
  tags = local.tags
}

resource "azurerm_network_security_group" "example" {
  name                = "example-nsg"
  location            = azurerm_resource_group.Terrarg.location
  resource_group_name = azurerm_resource_group.Terrarg.name
}

resource "azurerm_network_security_rule" "inbound-ssh" {
  name                        = "allow-ssh-inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.example.name
  resource_group_name = azurerm_resource_group.Terrarg.name
  depends_on = [azurerm_network_security_group.example]
}

resource "azurerm_network_security_rule" "inbound-http" {
  name                        = "allow-http-inbound"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.example.name
  resource_group_name = azurerm_resource_group.Terrarg.name
  depends_on = [azurerm_network_security_group.example]
}

resource "azurerm_network_security_rule" "inbound-https" {
  name                        = "allow-https-inbound"
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.example.name
  resource_group_name = azurerm_resource_group.Terrarg.name
  depends_on = [azurerm_network_security_group.example]
}

resource "azurerm_network_security_rule" "inbound-all" {
  name                        = "allow-all-inbound"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.example.name
  resource_group_name = azurerm_resource_group.Terrarg.name
  depends_on = [azurerm_network_security_group.example]
}

resource "azurerm_network_security_rule" "outbound-all" {
  name                        = "allow-all-outbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.example.name
  resource_group_name = azurerm_resource_group.Terrarg.name
  depends_on = [azurerm_network_security_group.example]
}

resource "azurerm_network_interface_security_group_association" "terransg" {
  network_interface_id = azurerm_network_interface.terranic.id
  network_security_group_id = azurerm_network_security_group.example.id
}

resource "azurerm_network_interface" "terranic" {
  name                = "terranic"
  location            = azurerm_resource_group.Terrarg.location
  resource_group_name = azurerm_resource_group.Terrarg.name


  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.terrasubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.terra-pub-ip.id
    }
  tags = local.tags
}

resource "azurerm_linux_virtual_machine" "terra-docker-vm" {
  name                = var.bundle_name+"_"+var.env_name
  resource_group_name = azurerm_resource_group.Terrarg.name
  location            = azurerm_resource_group.Terrarg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.terranic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDYv0k85GSQpOEsoQBAPVglUjRqz9qI/e1Qq+Q6pBVP36ejqhEI7ReJvXwmWNgTlJdUc4Zya8T7vfXUDWeSWZtzVh8y7Mava0oWenzwneBWzZa2rshs0vlSILE1+Gu5lspY4oxbBqAzvGdhT3DaNkKziz5DVCeO+sA0iYVD4FydsLfSX8NtL5+Zai6bQbRwmi2LZzL2ibsiqcKKVRfoBvQI5/EK2vxSqEOFgPi4jQ0ldXYrQTLFjX/2NApoe6D/dUhQtTWdNc25rhLBUILm8Zes3pcCNterf4jSp5O4bcO8sMNxwAH1ghOgW21r0Mvuil2OkcdU63zyzOG0BIstqaIF rsa-key-20230420"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "8-gen2"
    version   = "latest"
  }
  tags = local.tags
}
