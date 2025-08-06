# Login Enterprise Azure Deployment with Terraform

This Terraform configuration deploys a Login Enterprise VHD virtual appliance to Microsoft Azure.

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

3. **VHD File**: Download the Login Enterprise VHD for Azure

## Quick Start

1. **Navigate to the deployment directory**:
   ```bash
   cd Terraform-Appliance-Deploy-Azure
   ```

2. **Update the variables**:
   Edit `vars.auto.tfvars` and update:
   - `vhd_path`: Path to your Login Enterprise VHD file
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

#### Option 1: Create New VNet and Subnet (Default)
```hcl
create_vnet = true
create_subnet = true
```

#### Option 2: Use Existing VNet and Subnet
```hcl
create_vnet = false
create_subnet = false
existing_vnet_name = "my-existing-vnet"
existing_subnet_name = "default"
```

#### Option 3: Mixed Configuration
```hcl
# Use existing VNet, create new subnet
create_vnet = false
create_subnet = true
existing_vnet_name = "my-existing-vnet"

# Create new VNet, use existing subnet
create_vnet = true
create_subnet = false
existing_subnet_name = "default"
```

#### Cross-Resource Group Support
If your VNet or subnet exists in a different resource group:
```hcl
vnet_resource_group = "my-vnet-rg"
subnet_resource_group = "my-subnet-rg"
```

### VM Configuration

- **VM Size**: Default is `Standard_D2s_v3` (2 vCPUs, 8 GB RAM)
- **Location**: Default is `UK South`
- **Admin Username**: `azureuser` (Azure requirement)
- **Authentication**: Password-based authentication

### Security

- **HTTPS Access**: Enabled on port 443
- **HTTP Access**: Enabled on port 80
- **Network Security Group**: Automatically created with required rules

## Outputs

After successful deployment, Terraform will output:

- **VM Name**: Name of the deployed virtual machine
- **Resource Group**: Name of the resource group
- **Public IP**: Public IP address of the VM
- **Domain Name**: Azure DNS name (e.g., `le12345.uksouth.cloudapp.azure.com`)
- **Appliance URL**: HTTPS URL to access Login Enterprise

## Cloud-Init Configuration

The deployment uses the same cloud-init configuration as the Ansible deployment:

- Sets the admin password
- Configures the domain name
- Runs the Login Enterprise first-run setup

## Cleanup

To remove all resources:
```bash
terraform destroy
```

## Troubleshooting

### Common Issues

1. **VHD Upload Fails**: Ensure the VHD file path is correct and accessible
2. **Network Configuration**: Check VNet/subnet names and resource groups
3. **Storage Account Name**: Names must be globally unique (random suffix helps)

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
Terraform-Appliance-Deploy-Azure/
├── main.tf              # Main Terraform configuration
├── variables.tf         # Variable definitions
├── output.tf           # Output definitions
├── vars.auto.tfvars    # Variable values
├── templates/
│   └── userdata.yml    # Cloud-init configuration
└── README.md           # This file
```