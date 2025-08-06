#===========================#
# VMware vCenter connection #
#===========================#

variable "vsphere_user" {
  type        = string
  description = "vSphere username"
  sensitive   = true
}

variable "vsphere_password" {
  type        = string
  description = "vSphere password"
  sensitive   = true
}

variable "vsphere_server" {
  type        = string
  description = "vSphere/vCenter server FQDN or IP"
  sensitive   = true
}

variable "vsphere_unverified_ssl" {
  type        = string
  description = "Ignore SSL warning in the case of a self-signed certificate"
  default     = true
}

#===============================#
# VMware vSphere infrastructure #
#===============================#

variable "vsphere_datacenter" {
  type        = string
  description = "vCenter datacenter"
}

variable "vsphere_cluster" {
  type        = string
  description = "vCenter cluster"
}

variable "vsphere_datastore" {
  type        = string
  description = "vSphere datastore"
}

variable "vsphere_host" {
  type        = string
  description = "Name of the vSphere host to deploy the OVA to"
}

#================================#
# VMware vSphere virtual machine #
#================================#

variable "vm_name" {
  type        = string
  description = "The name of the virtual machine"
}

variable "vm_network" {
  type        = string
  description = "Network used for the virtual machine"
  default     = "VM Network"
}

variable "cpu" {
  description = "Number of vCPU for the virtual machine"
  default     = 4
}

variable "cores_per_socket" {
  description = "Number of cores per socket for the virtual machine"
  default     = 4
}

variable "memory" {
  description = "Amount of RAM for the virtual machine (example: 8192)"
  default     = 8192
}

variable "disksize" {
  description = "Disk size in GB for the virtual machine (example: 100 for 100 GB)"
  default     = 100
}

#============================#
# Login Enterprise Appliance #
#============================#

variable "host_name" {
  type        = string
  description = "Hostname of the Login Enterprise appliance. This, along with the domain_name, make up the FQDN of the appliance."
}

variable "domain_name" {
  type        = string
  description = "Domain name of the Login Enterprise appliance. This, along with the host_name, make up the FQDN of the appliance."
}

variable "admin_password" {
  type        = string
  description = "Password to set for the admin user. Password should be base64 encoded."
  sensitive   = true
}

variable "set_static_ip" {
  type        = string
  description = "Login Enterprise appliance will use DHCP by default to acquire an ip, set this to true to use static ip"
  default     = false
}

variable "network_interface" {
  type        = string
  description = ""
  default     = "ens192"
}

variable "ipv4_address" {
  type    = string
  default = ""
}

variable "ipv4_gateway" {
  type    = string
  default = ""
}

variable "ipv4_netmask" {
  type    = string
  default = ""
}

variable "dns_server_list" {
  type        = list(string)
  description = "List of DNS servers"
  default     = ["4.4.4.4", "8.8.8.8"]
}

variable "search_domain" {
  type        = string
  description = ""
  default     = ""
}

variable "ova_path" {
  type        = string
  description = "Path to the OVA file. For UNC path, replace backslash with forward slash or escape the backslash with an additional backslash."
}