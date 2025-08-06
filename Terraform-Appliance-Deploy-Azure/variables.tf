#===========================#
# Azure Configuration       #
#===========================#

variable "location" {
  type        = string
  description = "Azure region for deployment"
  default     = "UK South"
}

variable "vm_size" {
  type        = string
  description = "Azure VM size"
  default     = "Standard_D2s_v3"
}

variable "vhd_path" {
  type        = string
  description = "Path to the VHD file for the Login Enterprise appliance"
}

#============================#
# Login Enterprise Appliance #
#============================#

variable "admin_password" {
  type        = string
  description = "Password to set for the admin user. Password should be base64 encoded."
  sensitive   = true
}

variable "vm_name" {
  type        = string
  description = "Base name for the virtual machine (will be suffixed with random string)"
  default     = "login-enterprise"
}

#============================#
# Network Configuration      #
#============================#

variable "create_vnet" {
  type        = bool
  description = "Whether to create a new virtual network"
  default     = true
}

variable "create_subnet" {
  type        = bool
  description = "Whether to create a new subnet"
  default     = true
}

variable "existing_vnet_name" {
  type        = string
  description = "Name of existing virtual network (if create_vnet = false)"
  default     = ""
}

variable "existing_subnet_name" {
  type        = string
  description = "Name of existing subnet (if create_subnet = false)"
  default     = "default"
}

variable "vnet_resource_group" {
  type        = string
  description = "Resource group containing the existing VNet (if different from deployment RG)"
  default     = ""
}

variable "subnet_resource_group" {
  type        = string
  description = "Resource group containing the existing subnet (if different from VNet RG)"
  default     = ""
} 