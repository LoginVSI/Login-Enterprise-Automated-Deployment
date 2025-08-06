output "vm_name" {
  description = "Name of the deployed virtual machine"
  value       = azurerm_virtual_machine.vm.name
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "public_ip_address" {
  description = "Public IP address of the virtual machine"
  value       = azurerm_public_ip.pip.ip_address
}

output "domain_name" {
  description = "Azure DNS name for the virtual machine"
  value       = azurerm_public_ip.pip.fqdn
}

output "appliance_url" {
  description = "HTTPS URL to access the Login Enterprise appliance"
  value       = "https://${azurerm_public_ip.pip.fqdn}"
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.storage.name
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = var.create_vnet ? azurerm_virtual_network.vnet[0].name : var.existing_vnet_name
}

output "subnet_name" {
  description = "Name of the subnet"
  value       = var.create_subnet ? azurerm_subnet.subnet[0].name : var.existing_subnet_name
} 