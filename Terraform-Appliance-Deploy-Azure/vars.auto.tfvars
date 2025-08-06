#===========================#
# Azure Configuration       #
#===========================#
location = "UK South"
vm_size  = "Standard_D4s_v3"

#============================#
# Login Enterprise Appliance #
#============================#
admin_password = "UGFzc3dvcmQxMDAK"  # Base64 encoded "Password100"

#=================#
# VHD Configuration #
#=================#
vhd_path = "/Users/username/Downloads/AZ-VA-LoginEnterprise-6.1.14.vhd"  # Update this path to your VHD file

#============================#
# Network Configuration      #
#============================#
create_vnet = true
create_subnet = true

# Optional: Use existing VNet/Subnet (set create_vnet/create_subnet to false)
# existing_vnet_name = "my-existing-vnet"
# existing_subnet_name = "default"
# vnet_resource_group = "my-vnet-rg"
# subnet_resource_group = "my-subnet-rg" 