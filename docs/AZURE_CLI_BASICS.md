# Azure CLI Basics

A comprehensive guide to understanding and using Azure Command Line Interface effectively.

## Table of Contents

1. [What is Azure CLI?](#what-is-azure-cli)
1. [Installation](#installation)
1. [Authentication](#authentication)
1. [Azure Hierarchy](#azure-hierarchy)
1. [Command Structure](#command-structure)
1. [Output Formats](#output-formats)
1. [Querying Results](#querying-results)
1. [Configuration](#configuration)
1. [Common Patterns](#common-patterns)

## What is Azure CLI?

Azure CLI (Command Line Interface) is a cross-platform command-line tool that provides a set of commands for managing Azure resources. It’s designed to be:

- **Cross-platform**: Works on Windows, macOS, and Linux
- **Scriptable**: Perfect for automation and CI/CD pipelines
- **Interactive**: Supports tab completion and interactive mode
- **Consistent**: Follows predictable command patterns
- **JSON-based**: Returns structured data for easy parsing

### Why Use Azure CLI?

- **Automation**: Script repetitive tasks
- **CI/CD Integration**: Deploy infrastructure as code
- **Learning**: Understand Azure resource management
- **Efficiency**: Faster than navigating the portal for many tasks
- **Version Control**: Store infrastructure definitions in Git

## Installation

### Windows

**Option 1: MSI Installer (Recommended)**

```powershell
# Download from: https://aka.ms/installazurecliwindows
# Or use winget:
winget install Microsoft.AzureCLI
```

**Option 2: Using PowerShell**

```powershell
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi
Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
```

### macOS

**Using Homebrew (Recommended)**

```bash
brew update && brew install azure-cli
```

### Linux

**Ubuntu/Debian**

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

**RHEL/CentOS/Fedora**

```bash
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo dnf install azure-cli
```

**Manual Installation**

```bash
curl -L https://aka.ms/InstallAzureCli | bash
```

### Docker

```bash
docker run -it mcr.microsoft.com/azure-cli
```

### Verification

```bash
az --version
```

Expected output:

```
azure-cli                         2.50.0
core                              2.50.0
telemetry                          1.0.8
...
```

## Authentication

### Interactive Login

The most common method for personal use:

```bash
az login
```

This opens a browser window for authentication. After successful login, you’ll see your subscriptions listed.

### Service Principal Login

For automation and CI/CD:

```bash
az login --service-principal \
  --username APP_ID \
  --password PASSWORD_OR_CERT \
  --tenant TENANT_ID
```

### Managed Identity

For resources running in Azure:

```bash
az login --identity
```

### Device Code Flow

For headless systems or restricted environments:

```bash
az login --use-device-code
```

### Check Authentication Status

```bash
# Show current account
az account show

# List all subscriptions
az account list --output table

# Check current tenant
az account show --query tenantId
```

### Logout

```bash
az logout
```

## Azure Hierarchy

Understanding Azure’s organizational structure is crucial:

```
Management Group (Optional)
    └── Subscription (Billing boundary)
        └── Resource Group (Logical container)
            └── Resources (VMs, Storage, etc.)
```

### Key Concepts

**1. Subscription**

- Billing and access boundary
- Can have multiple subscriptions per account
- Each subscription has resource limits (quotas)

**2. Resource Group**

- Logical container for resources
- All resources must belong to exactly one resource group
- Can contain resources from different locations
- Lifecycle management: Delete RG = Delete all resources

**3. Resource**

- Individual Azure service (VM, Storage Account, etc.)
- Identified by unique Resource ID
- Can have tags for organization

### Working with Subscriptions

```bash
# List all subscriptions
az account list --output table

# Show current subscription
az account show

# Switch subscription
az account set --subscription "My Subscription"
az account set --subscription "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# Get subscription ID
az account show --query id --output tsv
```

## Command Structure

Azure CLI follows a consistent, hierarchical command structure:

```
az <group> <subgroup> <action> [parameters]
```

### Examples

```bash
# Group: vm, Action: create
az vm create --resource-group myRG --name myVM --image UbuntuLTS

# Group: storage, Subgroup: account, Action: list
az storage account list

# Group: network, Subgroup: vnet, Action: create
az network vnet create --name myVNet --resource-group myRG
```

### Common Command Groups

|Group        |Purpose                |Examples                    |
|-------------|-----------------------|----------------------------|
|`az account` |Subscription management|`az account list`           |
|`az group`   |Resource groups        |`az group create`           |
|`az vm`      |Virtual machines       |`az vm create`, `az vm list`|
|`az storage` |Storage services       |`az storage account create` |
|`az network` |Networking             |`az network vnet create`    |
|`az webapp`  |Web apps               |`az webapp create`          |
|`az sql`     |SQL databases          |`az sql server create`      |
|`az keyvault`|Key Vault              |`az keyvault create`        |
|`az aks`     |Kubernetes             |`az aks create`             |

### Getting Help

```bash
# General help
az --help

# Group help
az vm --help

# Command help
az vm create --help

# Find commands
az find "virtual machine"
az find "blob storage"
```

## Output Formats

Azure CLI supports multiple output formats for different use cases.

### JSON (Default)

Structured data, perfect for programmatic parsing:

```bash
az group list
az group list --output json  # Explicit
```

Output:

```json
[
  {
    "id": "/subscriptions/.../resourceGroups/myRG",
    "location": "eastus",
    "name": "myRG",
    "properties": {
      "provisioningState": "Succeeded"
    }
  }
]
```

### Table

Human-readable format:

```bash
az group list --output table
```

Output:

```
Name    Location    Status
------  ----------  ---------
myRG    eastus      Succeeded
testRG  westus      Succeeded
```

### TSV (Tab-Separated Values)

Great for shell scripting:

```bash
az group list --output tsv
```

Use in scripts:

```bash
while IFS=$'\t' read -r name location status; do
  echo "RG: $name in $location"
done < <(az group list --output tsv --query "[].{Name:name, Location:location, Status:properties.provisioningState}")
```

### YAML

Configuration-friendly format:

```bash
az group list --output yaml
```

### JSON with Colors (jsonc)

Enhanced JSON for terminal viewing:

```bash
az group list --output jsonc
```

### Setting Default Output

```bash
# Set table as default
az config set core.output=table

# Reset to JSON
az config set core.output=json
```

## Querying Results

Azure CLI uses JMESPath for querying JSON results.

### Basic Queries

**Get specific field:**

```bash
# Get all resource group names
az group list --query "[].name"

# Get current subscription ID
az account show --query id
```

**Array indexing:**

```bash
# Get first resource group
az group list --query "[0]"

# Get last resource group
az group list --query "[-1]"
```

### Filtering

**Basic filtering:**

```bash
# Get RGs in eastus
az group list --query "[?location=='eastus']"

# Get running VMs
az vm list --query "[?powerState=='VM running']"
```

**Multiple conditions:**

```bash
# RGs in eastus or westus
az group list --query "[?location=='eastus' || location=='westus']"

# VMs that are running AND in specific RG
az vm list --query "[?powerState=='VM running' && resourceGroup=='myRG']"
```

### Projection (Custom Output)

**Select specific fields:**

```bash
# Get name and location only
az group list --query "[].{Name:name, Location:location}"

# Custom column names
az vm list --query "[].{VMName:name, RG:resourceGroup, State:powerState}"
```

**Combine with table output:**

```bash
az vm list --query "[].{Name:name, ResourceGroup:resourceGroup, State:powerState}" --output table
```

### Advanced Queries

**Sorting:**

```bash
# Sort by name
az group list --query "sort_by([], &name)"

# Sort by location
az group list --query "sort_by([], &location)"
```

**String operations:**

```bash
# Contains check
az vm list --query "[?contains(name, 'prod')]"

# Starts with
az vm list --query "[?starts_with(name, 'web')]"
```

**Length and counting:**

```bash
# Count resource groups
az group list --query "length([])"

# Count VMs in specific state
az vm list --query "length([?powerState=='VM running'])"
```

### Common Query Patterns

```bash
# Get all VM names as simple list
az vm list --query "[].name" --output tsv

# Get public IP addresses of all VMs
az vm list --show-details --query "[].publicIps" --output tsv

# Get storage account keys
az storage account keys list --account-name myaccount --query "[0].value" --output tsv

# List all resources of specific type
az resource list --resource-type "Microsoft.Compute/virtualMachines" --query "[].name"

# Get resource IDs
az vm list --query "[].id" --output tsv
```

## Configuration

Azure CLI stores configuration in `~/.azure/config` (Linux/Mac) or `%USERPROFILE%\.azure\config` (Windows).

### View Configuration

```bash
# Show all config
az config get

# Show specific setting
az config get core.output
```

### Set Configuration

**Default location:**

```bash
az config set defaults.location=eastus
```

Now commands use eastus by default:

```bash
# No need to specify --location
az group create --name myRG
```

**Default resource group:**

```bash
az config set defaults.group=myResourceGroup
```

**Default output format:**

```bash
az config set core.output=table
```

**Disable telemetry:**

```bash
az config set core.collect_telemetry=false
```

**Enable auto-upgrade:**

```bash
az config set auto-upgrade.enable=yes
```

### Unset Configuration

```bash
az config unset defaults.location
```

### Configuration File Location

```bash
# Linux/macOS
~/.azure/config

# Windows
%USERPROFILE%\.azure\config
```

Example config file:

```ini
[defaults]
location = eastus
group = myResourceGroup

[core]
output = table
collect_telemetry = false
```

## Common Patterns

### Pattern 1: Create Resource, Get Properties

```bash
# Create and capture output
RESULT=$(az group create --name myRG --location eastus)

# Extract specific field
RG_ID=$(az group show --name myRG --query id --output tsv)

# Or in one command
az group create --name myRG --location eastus --query id --output tsv
```

### Pattern 2: List and Filter

```bash
# List all, filter by criteria
az vm list --query "[?powerState=='VM running'].name" --output tsv

# Pipe to other commands
az group list --query "[].name" --output tsv | while read rg; do
  echo "Processing $rg"
done
```

### Pattern 3: Batch Operations

```bash
# Stop all VMs in a resource group
az vm list --resource-group myRG --query "[].id" --output tsv | \
  xargs -I {} az vm deallocate --ids {}

# Delete all resource groups with specific tag
az group list --tag Environment=Test --query "[].name" --output tsv | \
  xargs -I {} az group delete --name {} --yes --no-wait
```

### Pattern 4: Conditional Creation

```bash
# Create only if doesn't exist
if ! az group show --name myRG &>/dev/null; then
  az group create --name myRG --location eastus
fi
```

### Pattern 5: Error Handling

```bash
# Capture exit code
if az vm start --name myVM --resource-group myRG; then
  echo "VM started successfully"
else
  echo "Failed to start VM"
  exit 1
fi

# Suppress errors
az vm show --name nonexistent --resource-group myRG 2>/dev/null || echo "VM not found"
```

### Pattern 6: Using Variables

```bash
# Define variables
RG_NAME="myResourceGroup"
LOCATION="eastus"
VM_NAME="myVM"

# Use in commands
az group create --name $RG_NAME --location $LOCATION
az vm create --resource-group $RG_NAME --name $VM_NAME --image UbuntuLTS
```

### Pattern 7: JSON Processing

```bash
# Save JSON output
az vm list > vms.json

# Process with jq
az vm list | jq '.[] | select(.powerState=="VM running") | .name'

# Pretty print
az vm show --name myVM --resource-group myRG | jq '.'
```

## Best Practices for Beginners

1. **Start with `--help`**: Always read command help before using
1. **Use `--output table`**: Easier to read while learning
1. **Test with `--dry-run`**: When available, preview changes
1. **Set defaults**: Configure location and resource group
1. **Use interactive mode**: `az interactive` for learning
1. **Practice queries**: Master JMESPath for efficient filtering
1. **Version control scripts**: Store automation in Git
1. **Clean up resources**: Delete test resources to avoid charges

## Next Steps

Now that you understand the basics:

1. ✅ Install Azure CLI
1. ✅ Login and verify authentication
1. ✅ Understand command structure
1. ✅ Practice with output formats
1. ✅ Learn JMESPath queries
1. ✅ Configure defaults
1. 📖 Read <BEST_PRACTICES.md>
1. 🔧 Try the examples in `/examples/`
1. 🚀 Build your first automation script

## Useful Resources

- [Official Documentation](https://docs.microsoft.com/en-us/cli/azure/)
- [JMESPath Tutorial](https://jmespath.org/tutorial.html)
- [Azure CLI GitHub](https://github.com/Azure/azure-cli)
- [Command Reference](https://docs.microsoft.com/en-us/cli/azure/reference-index)
- [Interactive Learning](https://docs.microsoft.com/en-us/learn/modules/control-azure-services-with-cli/)

## Quick Command Reference

```bash
# Authentication
az login
az logout
az account show

# Resource Groups
az group create --name RG --location LOC
az group list
az group delete --name RG

# Common Operations
az vm list
az storage account list
az network vnet list

# Help
az --help
az vm --help
az vm create --help

# Configuration
az config set defaults.location=eastus
az config get

# Querying
az vm list --query "[].name"
az vm list --output table
```

Happy learning! 🎓
