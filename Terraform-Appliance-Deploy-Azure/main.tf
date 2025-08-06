terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Generate random suffix for unique resource names
resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false
}

locals {
  # Resource names with random suffix
  resource_group_name = "login-enterprise-rg-${random_string.suffix.result}"
  vm_name             = "login-enterprise-${random_string.suffix.result}"
  storage_account_name = "leappliance${random_string.suffix.result}"
  vnet_name           = "login-enterprise-vnet-${random_string.suffix.result}"
  subnet_name         = "default"
  nsg_name            = "login-enterprise-${random_string.suffix.result}-nsg"
  public_ip_name      = "login-enterprise-${random_string.suffix.result}-pip"
  nic_name            = "login-enterprise-${random_string.suffix.result}-nic"
  
  # Domain name for Azure - use le-{suffix} to avoid restricted word "login"
  domainname = "le-${random_string.suffix.result}.${replace(lower(var.location), " ", "")}.cloudapp.azure.com"
  
  # Template variables for cloud-init
  templatevars = {
    admin_password = var.admin_password
    domainname     = local.domainname
  }
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = var.location
}

# Storage Account
resource "azurerm_storage_account" "storage" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Storage Container
resource "azurerm_storage_container" "container" {
  name                  = "vhds"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

# Upload VHD to storage
resource "azurerm_storage_blob" "vhd" {
  name                   = "${var.vm_name}.vhd"
  storage_account_name   = azurerm_storage_account.storage.name
  storage_container_name = azurerm_storage_container.container.name
  type                  = "Page"
  source                = var.vhd_path
}

# Virtual Network (conditional creation)
resource "azurerm_virtual_network" "vnet" {
  count               = var.create_vnet ? 1 : 0
  name                = local.vnet_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}

# Subnet (conditional creation)
resource "azurerm_subnet" "subnet" {
  count                = var.create_subnet ? 1 : 0
  name                 = local.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = var.create_vnet ? azurerm_virtual_network.vnet[0].name : var.existing_vnet_name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group
resource "azurerm_network_security_group" "nsg" {
  name                = local.nsg_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Public IP
resource "azurerm_public_ip" "pip" {
  name                = local.public_ip_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  domain_name_label   = "le-${random_string.suffix.result}"
}

# Network Interface
resource "azurerm_network_interface" "nic" {
  name                = local.nic_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.create_subnet ? azurerm_subnet.subnet[0].id : data.azurerm_subnet.existing_subnet[0].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

# Attach NSG to NIC
resource "azurerm_network_interface_security_group_association" "nsg_association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Data source for existing VNet (if not creating)
data "azurerm_virtual_network" "existing_vnet" {
  count               = var.create_vnet ? 0 : 1
  name                = var.existing_vnet_name
  resource_group_name = var.vnet_resource_group != "" ? var.vnet_resource_group : azurerm_resource_group.rg.name
}

# Data source for existing Subnet (if not creating)
data "azurerm_subnet" "existing_subnet" {
  count                = var.create_subnet ? 0 : 1
  name                 = var.existing_subnet_name
  virtual_network_name = var.create_vnet ? azurerm_virtual_network.vnet[0].name : var.existing_vnet_name
  resource_group_name  = var.subnet_resource_group != "" ? var.subnet_resource_group : (var.vnet_resource_group != "" ? var.vnet_resource_group : azurerm_resource_group.rg.name)
}

# Virtual Machine from VHD
resource "azurerm_virtual_machine" "vm" {
  name                = local.vm_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  vm_size             = var.vm_size
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  # Use unmanaged disk from VHD
  storage_os_disk {
    name          = "${local.vm_name}-osdisk"
    image_uri     = azurerm_storage_blob.vhd.url
    vhd_uri       = "${azurerm_storage_account.storage.primary_blob_endpoint}${azurerm_storage_container.container.name}/${local.vm_name}-osdisk.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
    os_type       = "Linux"
  }

  os_profile {
    computer_name  = local.vm_name
    admin_username = "azureuser"
    admin_password = var.admin_password
    custom_data    = base64encode(templatefile("${path.module}/templates/userdata.yml", local.templatevars))
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    Environment = "Production"
    Project     = "Login Enterprise"
  }
} 