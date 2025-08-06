output "appliance_fqdn" {
  value = "${var.host_name}.${var.domain_name}"
}

output "appliance_url" {
  value = "https://${var.host_name}.${var.domain_name}"
}

output "vm_name" {
  value = var.vm_name
}

output "vm_ip" {
  value = resource.vsphere_virtual_machine.vm.*.guest_ip_addresses
}