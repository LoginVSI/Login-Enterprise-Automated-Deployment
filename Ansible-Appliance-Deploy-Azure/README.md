# Login Enterprise Azure Deployment with Ansible

This Ansible playbook deploys a Login Enterprise VHD virtual appliance to Microsoft Azure using Azure CLI commands.

## Prerequisites

1. **Azure CLI**: Install and authenticate with Azure
   
   **macOS/Linux**:
   ```bash
   # Install Azure CLI
   brew install azure-cli
   
   # Login to Azure
   az login
   ```
   
   **Windows**:
   ```powershell
   # Install Azure CLI
   winget install Microsoft.AzureCLI
   # Or download from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows
   
   # Login to Azure
   az login
   ```

2. **Ansible**: Install Ansible
   
   **macOS/Linux**:
   ```bash
   # Install Ansible
   brew install ansible
   ```
   
   **Note**: Ansible is not available on Windows. Use WSL (Windows Subsystem for Linux) or a Linux VM to run Ansible deployments.

3. **VHD File**: Download the Login Enterprise VHD for Azure

## Quick Start

1. **Navigate to the deployment directory**:
   ```bash
   cd Ansible-Appliance-Deploy-Azure
   ```

2. **Update the variables**:
   Edit the playbook variables section and update:
   - `vhd_path`: Path to your Login Enterprise VHD file
   - `admin_password`: Base64 encoded admin password

3. **Run the deployment**:
   ```bash
   ansible-playbook deploy_login_enterprise.yml
   ```

## Configuration Options

### Network Configuration

The deployment supports flexible network configuration:

#### Option 1: Create New VNet and Subnet (Default)
```yaml
create_vnet: true
create_subnet: true
```

#### Option 2: Use Existing VNet and Subnet
```yaml
create_vnet: false
create_subnet: false
existing_vnet_name: "my-existing-vnet"
existing_subnet_name: "default"
```

#### Option 3: Mixed Configuration
```yaml
# Use existing VNet, create new subnet
create_vnet: false
create_subnet: true
existing_vnet_name: "my-existing-vnet"

# Create new VNet, use existing subnet
create_vnet: true
create_subnet: false
existing_subnet_name: "default"
```

#### Cross-Resource Group Support
If your VNet or subnet exists in a different resource group:
```yaml
vnet_resource_group: "my-vnet-rg"
subnet_resource_group: "my-subnet-rg"
```

### VM Configuration

- **VM Size**: Default is `Standard_D4s_v3` (4 vCPUs, 16 GB RAM)
- **Location**: Default is `UK South`
- **Admin Username**: `admin` (Azure requirement)
- **Authentication**: Password-based authentication

### Security

- **HTTPS Access**: Enabled on port 443
- **HTTP Access**: Enabled on port 80
- **Network Security Group**: Automatically created with required rules

## Deployment Process

The playbook performs the following steps:

1. **Generate Random Suffix**: Creates unique resource names
2. **Create Resource Group**: Sets up the Azure resource group
3. **Upload VHD**: Uploads the VHD file to Azure Storage
4. **Create Network Infrastructure**: Sets up VNet, Subnet, NSG, Public IP, NIC
5. **Deploy VM**: Creates the VM from the uploaded VHD
6. **Configure Cloud-Init**: Applies the userdata configuration
7. **Display Results**: Shows deployment information and access details

## Outputs

After successful deployment, the playbook will display:

- **VM Name**: Name of the deployed virtual machine
- **Resource Group**: Name of the resource group
- **Public IP**: Public IP address of the VM
- **Domain Name**: Azure DNS name (e.g., `le12345.uksouth.cloudapp.azure.com`)
- **Appliance URL**: HTTPS URL to access Login Enterprise

## Cloud-Init Configuration

The deployment uses the official Login Enterprise Azure cloud-init template:

- Sets the admin password
- Configures the domain name
- Runs the Login Enterprise first-run setup

## Error Handling

The playbook includes comprehensive error handling:

- **Automatic Cleanup**: Removes resource group on deployment failure
- **Retry Logic**: Waits for VM provisioning to complete
- **Error Reporting**: Displays detailed error messages

## Cleanup

To remove all resources:
```bash
az group delete --resource-group <resource-group-name> --yes
```

## Troubleshooting

### Common Issues

1. **VHD Upload Fails**: Ensure the VHD file path is correct and accessible
2. **Network Configuration**: Check VNet/subnet names and resource groups
3. **Storage Account Name**: Names must be globally unique (random suffix helps)
4. **Azure CLI Authentication**: Ensure you're logged in with `az login`

### Verification

1. **Check VM Status**:
   ```bash
   az vm show --resource-group <rg-name> --name <vm-name>
   ```

2. **Test Connectivity**:
   ```bash
   # Test HTTPS
   curl -k https://<domain-name>
   ```

3. **Check Cloud-Init Logs**:
   ```bash
   # Access via Azure Bastion or other methods
   sudo cat /var/log/cloud-init-output.log
   ```

## File Structure

```
Ansible-Appliance-Deploy-Azure/
├── deploy_login_enterprise.yml  # Main Ansible playbook
├── templates/
│   └── userdata.yml                   # Cloud-init configuration
└── README.md                          # This file
```