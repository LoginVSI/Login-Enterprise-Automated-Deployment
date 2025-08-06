# Login Enterprise vSphere Deployment with Terraform

This Terraform configuration deploys a Login Enterprise OVA virtual appliance to VMware vSphere.

## Prerequisites

1. **vSphere Environment**: Access to a vSphere/vCenter environment
   - vCenter server with appropriate permissions
   - Datacenter, cluster, datastore, and network configured
   - ESXi host available for deployment

2. **Terraform**: Install Terraform
   
   **macOS/Linux**:
   ```bash
   # Install Terraform
   brew install terraform
   ```
   
   **Windows**:
   ```powershell
   # Install Terraform using Chocolatey
   choco install terraform
   
   # Or download from: https://www.terraform.io/downloads.html
   # Extract to C:\terraform and add to PATH
   ```

3. **VMware Provider**: The vSphere provider is included in the Terraform configuration
   ```hcl
   required_providers {
     vsphere = {
       source  = "hashicorp/vsphere"
       version = "<= 2.6.1"
     }
   }
   ```

4. **Login Enterprise OVA**: Download the Login Enterprise OVA file
   - Available from Login Enterprise support portal
   - Ensure the OVA is compatible with your vSphere version

## Quick Start

1. **Navigate to the deployment directory**:
   ```bash
   cd Terraform-Appliance-Deploy-vSphere
   ```

2. **Update the variables**:
   Edit `vars.auto.tfvars` and update:
   - `vsphere_server`: Your vCenter server FQDN or IP
   - `vsphere_user`: vCenter username
   - `vsphere_password`: vCenter password
   - `ova_path`: Path to your Login Enterprise OVA file
   - `admin_password`: Base64 encoded admin password

3. **Initialize Terraform**:
   ```bash
   terraform init
   ```

4. **Plan the deployment**:
   ```bash
   terraform plan
   ```

5. **Deploy**:
   ```bash
   terraform apply
   ```

## Configuration Options

### Network Configuration

The deployment supports flexible network configuration:

#### Static IP Configuration (Default)
```hcl
set_static_ip = true
ipv4_address  = "192.168.1.100"
ipv4_netmask  = "255.255.255.0"
ipv4_gateway  = "192.168.1.1"
dns_server_list = ["8.8.8.8", "8.8.4.4"]
```

#### DHCP Configuration
```hcl
set_static_ip = false
# Remove or comment out static IP variables
```

### VM Configuration

- **CPU**: Default is 4 vCPUs
- **Memory**: Default is 8 GB RAM
- **Datastore**: Configured via variables
- **Network**: Configurable via variables
- **Admin Username**: `admin` (Login Enterprise default)

### Security

- **HTTPS Access**: Enabled on port 443
- **SSH Access**: Enabled on port 22
- **Admin Password**: Base64 encoded password set via cloud-init

## Deployment Process

The Terraform configuration performs the following steps:

1. **Deploy OVA**: Uploads and deploys the OVA file to vSphere
2. **Configure Guestinfo**: Sets cloud-init data via VMX parameters
3. **Power On VM**: Starts the virtual machine
4. **Wait for Boot**: Waits for the VM to be ready

## Cloud-Init Configuration

The deployment uses cloud-init to configure the Login Enterprise appliance:

- Sets the admin password (base64 encoded)
- Configures network settings (static IP or DHCP)
- Sets the hostname and domain name
- Runs the Login Enterprise first-run setup

## Outputs

After successful deployment, Terraform will output:

- **VM Name**: Name of the deployed virtual machine
- **IP Address**: IP address of the VM (static or DHCP)
- **Hostname**: Configured hostname
- **Domain Name**: Configured domain name
- **Appliance URL**: HTTPS URL to access Login Enterprise

## Cleanup

To remove all resources:
```bash
terraform destroy
```

## Troubleshooting

### Common Issues

1. **OVA Deployment Fails**: Check vCenter permissions and datastore space
2. **Cloud-Init Not Working**: Verify guestinfo parameters are set correctly
3. **Network Issues**: Check network configuration and static IP settings
4. **Authentication Issues**: Verify vCenter credentials and permissions

### Verification

1. **Check VM Status**:
   ```bash
   # Via vSphere Client or PowerCLI
   Get-VM -Name <vm-name>
   ```

2. **Test Connectivity**:
   ```bash
   # Test HTTPS
   curl -k https://<vm-ip>
   
   # Test SSH
   ssh admin@<vm-ip>
   ```

3. **Check Cloud-Init Logs**:
   ```bash
   ssh admin@<vm-ip> "sudo cat /var/log/cloud-init-output.log"
   ```

## File Structure

```
Terraform-Appliance-Deploy-vSphere/
├── main.tf              # Main Terraform configuration
├── variables.tf         # Variable definitions
├── output.tf           # Output definitions
├── vars.auto.tfvars    # Variable values
├── templates/
│   ├── metadata.yml    # Cloud-init metadata
│   └── userdata.yml    # Cloud-init userdata
└── README.md           # This file
```