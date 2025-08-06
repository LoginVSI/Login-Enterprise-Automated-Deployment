terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "<= 2.6.1"
    }
  }
}

provider "vsphere" {
  vsphere_server       = var.vsphere_server
  user                 = var.vsphere_user
  password             = var.vsphere_password
  allow_unverified_ssl = var.vsphere_unverified_ssl
}

locals {
  templatevars = {
    hostname         = var.host_name,
    domainname       = var.domain_name,
    adminpassword    = var.admin_password,
    networkinterface = var.network_interface,
    setstaticip      = var.set_static_ip,
    ipv4address      = var.ipv4_address,
    ipv4netmask      = var.ipv4_netmask,
    ipv4gateway      = var.ipv4_gateway,
    nameservers      = join(" ", var.dns_server_list),
    searchdomain     = var.search_domain
  }
}

data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}

data "vsphere_compute_cluster" "compute_cluster" {
  name          = var.vsphere_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.vm_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "host" {
  name          = var.vsphere_host
  datacenter_id = data.vsphere_datacenter.dc.id
}

/*
resource "vsphere_folder" "vm_folder" {
    path          = "LoginEnterprise"
    type          = "vm"
    datacenter_id = data.vsphere_datacenter.dc.id
}
*/

resource "vsphere_virtual_machine" "vm" {
  name             = var.vm_name
  resource_pool_id = data.vsphere_compute_cluster.compute_cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  datacenter_id    = data.vsphere_datacenter.dc.id
  host_system_id   = data.vsphere_host.host.id

  #folder = resource.vsphere_folder.vm_folder.path
  num_cpus             = var.cpu
  num_cores_per_socket = var.cores_per_socket
  memory               = var.memory

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  ovf_deploy {
    local_ovf_path    = var.ova_path
    disk_provisioning = "thin"
    ovf_network_map = {
      (var.vm_network) = data.vsphere_network.network.id
    }
  }

  extra_config = {
    "guestinfo.metadata"          = base64encode(templatefile("${path.module}/templates/metadata.yml", local.templatevars))
    "guestinfo.metadata.encoding" = "base64"
    "guestinfo.userdata"          = base64encode(templatefile("${path.module}/templates/userdata.yml", local.templatevars))
    "guestinfo.userdata.encoding" = "base64"
  }

  lifecycle {
    ignore_changes = [
      annotation,
      extra_config
    ]
  }
}