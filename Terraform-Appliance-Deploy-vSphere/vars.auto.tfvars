#===========================#
# VMware vCenter connection #
#===========================#
vsphere_user           = "administrator@vsphere.local"
vsphere_password       = "Password100"
vsphere_server         = "vcsa.lab.local"
vsphere_unverified_ssl = true

#===============================#
# VMware vSphere infrastructure #
#===============================#
vsphere_datacenter = "Lab"
vsphere_cluster    = "SM"
vsphere_datastore  = "ESX3_SSD"

#=================#
# Virtual Machine #
#=================#
vsphere_host     = "192.168.101.185"
vm_name          = "login-enterprise-001"
vm_network       = "LAB_110"
cpu              = 4
cores_per_socket = 4
memory           = 8192
disksize         = 100

#============================#
# Login Enterprise Appliance #
#============================#
host_name       = "LE-TEST"
domain_name     = "lab.local"
admin_password  = "UGFzc3dvcmQxMDA="
ova_path        = "/Users/username/Downloads/VA-LoginEnterprise-6.1.14.ova"
set_static_ip   = true             # appliance will use DHCP by default to acquire an ip, set this to true to use static ip
ipv4_address    = "192.168.1.67"      # used for static ip only, not required if using DHCP
ipv4_netmask    = "255.255.255.0"     # used for static ip only, not required if using DHCP
ipv4_gateway    = "192.168.1.1"   # used for static ip only, not required if using DHCP
dns_server_list = ["192.168.1.10", "192.168.2.17"] # used for static ip only, not required if using DHCP
search_domain   = "lab.local" # used for static ip only, not required if using DHCP