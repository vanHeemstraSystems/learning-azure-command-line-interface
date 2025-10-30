# Azure CLI Troubleshooting Guide

Comprehensive solutions to common Azure CLI problems and errors.

## Table of Contents

1. [Installation Issues](#installation-issues)
1. [Authentication Problems](#authentication-problems)
1. [Permission Errors](#permission-errors)
1. [Resource Creation Failures](#resource-creation-failures)
1. [Network and Connectivity](#network-and-connectivity)
1. [Performance Issues](#performance-issues)
1. [Output and Formatting](#output-and-formatting)
1. [Specific Resource Errors](#specific-resource-errors)
1. [General Debugging](#general-debugging)

## Installation Issues

### Problem: Command ‘az’ not found

**Symptoms:**

```bash
$ az --version
bash: az: command not found
```

**Solutions:**

**Linux/macOS:**

```bash
# Verify installation
which az

# If not in PATH, add to ~/.bashrc or ~/.zshrc
export PATH=$PATH:/usr/local/bin

# Or reinstall
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

**Windows:**

```powershell
# Check if installed
Get-Command az

# Add to PATH if installed but not found
$env:Path += ";C:\Program Files (x86)\Microsoft SDKs\Azure\CLI2\wbin"

# Or reinstall with winget
winget install Microsoft.AzureCLI
```

### Problem: Azure CLI won’t update

**Symptoms:**

```bash
$ az upgrade
ERROR: This command is in preview and under development.
```

**Solutions:**

```bash
# Method 1: Use package manager
# macOS
brew upgrade azure-cli

# Ubuntu/Debian
sudo apt-get update && sudo apt-get upgrade azure-cli

# Method 2: Reinstall
curl -L https://aka.ms/InstallAzureCli | bash

# Windows
winget upgrade Microsoft.AzureCLI
```

### Problem: SSL/TLS certificate errors

**Symptoms:**

```bash
SSL: CERTIFICATE_VERIFY_FAILED
```

**Solutions:**

```bash
# Temporary workaround (not recommended for production)
export AZURE_CLI_DISABLE_CERTIFICATE_VERIFICATION=1

# Better: Update certificates
# macOS
brew install openssl
pip install --upgrade certifi

# Linux
sudo apt-get install ca-certificates
sudo update-ca-certificates

# Windows
certutil -addstore -f "ROOT" certificate.cer
```

## Authentication Problems

### Problem: ‘az login’ fails silently

**Symptoms:**

```bash
$ az login
# Browser opens but nothing happens
```

**Solutions:**

```bash
# Method 1: Use device code flow
az login --use-device-code

# Method 2: Use service principal
az login --service-principal \
  --username APP_ID \
  --password PASSWORD \
  --tenant TENANT_ID

# Method 3: Clear cached credentials
rm -rf ~/.azure
az login

# Method 4: Check Azure CLI version
az --version
az upgrade
```

### Problem: “No subscriptions found”

**Symptoms:**

```bash
$ az login
WARNING: No subscriptions found for user@domain.com
```

**Solutions:**

```bash
# 1. Verify you have Azure subscriptions
# Login to portal.azure.com and check

# 2. Check tenant
az login --tenant TENANT_ID

# 3. List all accounts
az account list --all

# 4. Refresh tokens
az account clear
az login
```

### Problem: Token expired

**Symptoms:**

```bash
ERROR: The access token has expired
ERROR: AADSTS70043: The refresh token has expired
```

**Solutions:**

```bash
# Simple: Re-login
az logout
az login

# For automation: Use service principal
az login --service-principal \
  --username $APP_ID \
  --password $PASSWORD \
  --tenant $TENANT_ID

# Set token refresh
az account get-access-token --query accessToken --output tsv
```

### Problem: Wrong subscription selected

**Symptoms:**

```bash
ERROR: The subscription 'xxx' could not be found
```

**Solutions:**

```bash
# List all subscriptions
az account list --output table

# Set correct subscription
az account set --subscription "SUBSCRIPTION_NAME"
az account set --subscription "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# Verify current subscription
az account show --query "{Name:name, ID:id}" --output table

# Set default subscription
az account set --subscription "SUBSCRIPTION_NAME"
```

## Permission Errors

### Problem: “Authorization failed”

**Symptoms:**

```bash
ERROR: The client 'user@domain.com' with object id 'xxx' does not have authorization
to perform action 'Microsoft.Resources/subscriptions/resourcegroups/write'
```

**Solutions:**

```bash
# 1. Check your current role
az role assignment list --assignee user@domain.com --output table

# 2. Required roles by operation:
# - Reader: View resources
# - Contributor: Manage resources (most common)
# - Owner: Full control

# 3. Request appropriate role from admin
# Admin can grant with:
az role assignment create \
  --assignee user@domain.com \
  --role Contributor \
  --scope /subscriptions/{subscription-id}

# 4. Check specific resource permissions
az role assignment list \
  --scope /subscriptions/{sub-id}/resourceGroups/{rg-name} \
  --output table
```

### Problem: “Forbidden” errors

**Symptoms:**

```bash
ERROR: (Forbidden) The client does not have authorization
Status Code: 403
```

**Solutions:**

```bash
# Check your permissions on the resource
az role assignment list \
  --scope /subscriptions/{sub-id}/resourceGroups/{rg} \
  --assignee $(az account show --query user.name --output tsv) \
  --output table

# Request elevated permissions if needed
# Contact Azure subscription administrator

# Use a different account with proper permissions
az logout
az login --username other-user@domain.com
```

### Problem: “Subscription disabled”

**Symptoms:**

```bash
ERROR: The subscription is disabled and therefore marked as read only
```

**Solutions:**

```bash
# 1. Check subscription state
az account show --query state

# 2. Possible reasons:
# - Billing issue (payment failed)
# - Subscription expired
# - Disabled by admin

# 3. Resolution:
# - Contact billing administrator
# - Update payment method in portal
# - Re-enable subscription in portal
```

## Resource Creation Failures

### Problem: “Name already exists”

**Symptoms:**

```bash
ERROR: Storage account name 'mystorageaccount' is already taken
ERROR: The resource group 'myRG' already exists in location 'eastus'
```

**Solutions:**

```bash
# Check if resource exists
az storage account check-name --name mystorageaccount

# Use unique names
UNIQUE_SUFFIX=$(date +%s)
STORAGE_NAME="mystorage${UNIQUE_SUFFIX}"

az storage account create --name $STORAGE_NAME ...

# For resource groups, check first
if az group show --name myRG &>/dev/null; then
    echo "Resource group exists, skipping creation"
else
    az group create --name myRG --location eastus
fi
```

### Problem: “InvalidResourceNamespace”

**Symptoms:**

```bash
ERROR: The resource namespace 'microsoft.compute' is invalid
```

**Solutions:**

```bash
# Register the resource provider
az provider register --namespace Microsoft.Compute
az provider register --namespace Microsoft.Storage
az provider register --namespace Microsoft.Network

# Check registration status
az provider show --namespace Microsoft.Compute --query registrationState

# Wait for registration
az provider show --namespace Microsoft.Compute --query registrationState --output tsv

# Common providers:
# Microsoft.Compute, Microsoft.Storage, Microsoft.Network,
# Microsoft.Web, Microsoft.Sql, Microsoft.KeyVault
```

### Problem: “QuotaExceeded”

**Symptoms:**

```bash
ERROR: Operation results in exceeding quota limits of Core
Current usage: 20, Max limit: 20
```

**Solutions:**

```bash
# Check current usage
az vm list-usage --location eastus --output table

# View specific quota
az vm list-usage --location eastus \
  --query "[?name.value=='cores']" \
  --output table

# Solutions:
# 1. Delete unused resources
az vm list --query "[?powerState=='VM deallocated'].{Name:name, RG:resourceGroup}" --output table

# 2. Use different region
az vm create --location westus ...

# 3. Request quota increase
# Go to portal.azure.com -> Subscriptions -> Usage + quotas
# Or submit support ticket
```

### Problem: Resource name validation failed

**Symptoms:**

```bash
ERROR: Parameter name must match pattern ^[a-z0-9]
```

**Solutions:**

```bash
# Storage accounts: lowercase letters and numbers only, 3-24 chars
VALID_NAME="mystorage123"
az storage account create --name $VALID_NAME ...

# VMs: alphanumeric and hyphens
VALID_VM="my-vm-01"
az vm create --name $VALID_VM ...

# Resource groups: alphanumeric, periods, underscores, hyphens, parentheses
VALID_RG="my-resource-group_2024"
az group create --name $VALID_RG ...

# Check naming rules
az storage account check-name --name "MyStorageAccount" # Will fail
az storage account check-name --name "mystorageaccount" # Will succeed
```

## Network and Connectivity

### Problem: Timeout errors

**Symptoms:**

```bash
ERROR: Connection timeout
ERROR: Failed to establish a new connection
```

**Solutions:**

```bash
# 1. Check internet connection
ping management.azure.com

# 2. Check DNS resolution
nslookup management.azure.com

# 3. Check firewall/proxy
# If behind corporate proxy, configure:
export HTTP_PROXY=http://proxy.company.com:8080
export HTTPS_PROXY=http://proxy.company.com:8080
export NO_PROXY=localhost,127.0.0.1

# 4. Increase timeout (in ~/.azure/config)
[core]
request_timeout = 60

# 5. Try different Azure endpoint
az cloud set --name AzureUSGovernment
az cloud set --name AzureCloud  # Reset to public cloud
```

### Problem: “Cannot reach storage account”

**Symptoms:**

```bash
ERROR: Unable to reach storage account endpoint
```

**Solutions:**

```bash
# 1. Check if storage account exists
az storage account show --name mystorageaccount

# 2. Check network rules
az storage account show \
  --name mystorageaccount \
  --query networkRuleSet

# 3. Add your IP to firewall
MY_IP=$(curl -s ifconfig.me)
az storage account network-rule add \
  --account-name mystorageaccount \
  --ip-address $MY_IP

# 4. Temporarily allow all networks (for testing)
az storage account update \
  --name mystorageaccount \
  --default-action Allow
```

### Problem: “VM cannot be reached”

**Symptoms:**

```bash
ssh: connect to host XX.XX.XX.XX port 22: Connection refused
```

**Solutions:**

```bash
# 1. Check VM is running
az vm get-instance-view \
  --name myVM \
  --resource-group myRG \
  --query instanceView.statuses

# 2. Start VM if stopped
az vm start --name myVM --resource-group myRG

# 3. Check NSG rules
az network nsg rule list \
  --nsg-name myNSG \
  --resource-group myRG \
  --output table

# 4. Add rule to allow SSH
az network nsg rule create \
  --nsg-name myNSG \
  --resource-group myRG \
  --name AllowSSH \
  --priority 1000 \
  --destination-port-ranges 22 \
  --protocol Tcp \
  --access Allow

# 5. Get VM public IP
az vm list-ip-addresses \
  --name myVM \
  --resource-group myRG \
  --output table
```

## Performance Issues

### Problem: Commands are very slow

**Symptoms:**

```bash
$ time az vm list
# Takes 30+ seconds
```

**Solutions:**

```bash
# 1. Use --query to reduce data transfer
az vm list --query "[].{Name:name, State:powerState}" --output table

# 2. Filter at the server
az vm list --resource-group myRG  # Faster than filtering all VMs

# 3. Use --output tsv for less processing
az vm list --output tsv

# 4. Disable telemetry
az config set core.collect_telemetry=false

# 5. Update Azure CLI
az upgrade

# 6. Use --no-wait for long operations
az vm create --no-wait ...

# 7. Check network connectivity
ping management.azure.com
```

### Problem: “Too many requests”

**Symptoms:**

```bash
ERROR: Rate limit exceeded. Please retry after 60 seconds
Status Code: 429
```

**Solutions:**

```bash
# 1. Add delays between operations
for vm in vm1 vm2 vm3; do
    az vm create --name $vm ...
    sleep 5  # Wait 5 seconds
done

# 2. Use batch operations instead of loops
az vm start --ids $(az vm list --query "[].id" --output tsv)

# 3. Reduce parallel operations
# Use xargs -P to limit concurrency
echo "vm1 vm2 vm3" | xargs -P 2 -I {} az vm start --name {} ...

# 4. Implement exponential backoff
attempt=0
max_attempts=5
while [ $attempt -lt $max_attempts ]; do
    if az vm create ...; then
        break
    fi
    sleep $((2 ** attempt))
    attempt=$((attempt + 1))
done
```

## Output and Formatting

### Problem: JSON parsing errors

**Symptoms:**

```bash
ERROR: Failed to parse JSON
jq: parse error: Invalid numeric literal
```

**Solutions:**

```bash
# 1. Validate JSON output
az vm list | jq '.'

# 2. Use --output jsonc for debugging
az vm list --output jsonc

# 3. Handle empty results
RESULT=$(az vm list --resource-group nonexistent 2>/dev/null)
if [ -z "$RESULT" ] || [ "$RESULT" = "[]" ]; then
    echo "No VMs found"
fi

# 4. Use safer query patterns
# Instead of:
VM_NAME=$(az vm list --query [0].name)  # Fails if no VMs

# Use:
VM_NAME=$(az vm list --query "[0].name // 'default'" --output tsv)
```

### Problem: Table output is truncated

**Symptoms:**

```bash
$ az vm list --output table
Name          ResourceGroup    ...
----          -------------    ...
very-long-vm  very-long-rg     ...
# Content cut off
```

**Solutions:**

```bash
# 1. Use custom query to show only needed columns
az vm list --query "[].{VM:name, RG:resourceGroup, State:powerState}" --output table

# 2. Use JSON for complete data
az vm list --output json | jq '.[] | {name, resourceGroup, powerState}'

# 3. Increase terminal width
export COLUMNS=200
az vm list --output table

# 4. Use TSV for full data
az vm list --output tsv
```

## Specific Resource Errors

### Storage Account Errors

**Problem: “Storage account is too busy”**

```bash
# Solution: Wait and retry, or use different storage tier
az storage account create --sku Premium_LRS ...
```

**Problem: “Blob not found”**

```bash
# List blobs to verify name
az storage blob list \
  --account-name mystorageaccount \
  --container-name mycontainer \
  --output table

# Check container exists
az storage container exists \
  --account-name mystorageaccount \
  --name mycontainer
```

### Virtual Machine Errors

**Problem: “VM size not available”**

```bash
# Check available sizes in region
az vm list-sizes --location eastus --output table

# Use different size or region
az vm create --size Standard_B2s --location westus ...
```

**Problem: “OS disk not found”**

```bash
# Specify disk explicitly
az vm create \
  --attach-os-disk myDisk \
  --os-type Linux

# Or create new VM from image
az vm create --image UbuntuLTS ...
```

### Virtual Network Errors

**Problem: “Address space overlap”**

```bash
# Check existing VNets
az network vnet list --query "[].{Name:name, AddressSpace:addressSpace}" --output table

# Use non-overlapping CIDR
az network vnet create \
  --address-prefix 10.1.0.0/16  # Different from existing 10.0.0.0/16
```

## General Debugging

### Enable Verbose Output

```bash
# Verbose mode
az vm list --verbose

# Debug mode (very detailed)
az vm list --debug

# Both
az vm list --verbose --debug 2>&1 | tee debug.log
```

### Check Azure Service Health

```bash
# Check Azure status
az rest --method get \
  --url "https://management.azure.com/subscriptions/{sub-id}/providers/Microsoft.ResourceHealth/availabilityStatuses?api-version=2020-05-01"

# Or visit: https://status.azure.com
```

### Test Azure CLI Configuration

```bash
# Run self-test
az self-test

# Check version
az version

# Verify authentication
az account show

# Test basic operations
az group list --output table
```

### Clear Cache and Reset

```bash
# Clear all cached data
rm -rf ~/.azure/

# Reset configuration
az config unset defaults.location
az config unset defaults.group

# Reinstall extensions
az extension list --query "[].name" --output tsv | xargs -I {} az extension remove --name {}

# Relogin
az login
```

### Get Help

```bash
# Command help
az vm create --help

# Find related commands
az find "virtual machine"

# Interactive mode (with autocomplete)
az interactive

# Check documentation
# https://docs.microsoft.com/en-us/cli/azure/
```

## Common Error Messages Reference

|Error                         |Likely Cause                 |Quick Fix                             |
|------------------------------|-----------------------------|--------------------------------------|
|`az: command not found`       |CLI not installed/not in PATH|Reinstall or add to PATH              |
|`Please run 'az login'`       |Not authenticated            |`az login`                            |
|`The subscription is disabled`|Billing/admin issue          |Check portal, contact admin           |
|`Authorization failed`        |Insufficient permissions     |Request Contributor role              |
|`Name already exists`         |Resource name conflict       |Use unique name                       |
|`QuotaExceeded`               |Resource limit reached       |Delete resources or request increase  |
|`InvalidResourceNamespace`    |Provider not registered      |`az provider register --namespace ...`|
|`Connection timeout`          |Network/firewall issue       |Check connectivity, configure proxy   |
|`Rate limit exceeded`         |Too many requests            |Add delays, use batch operations      |
|`Token expired`               |Authentication timed out     |`az logout && az login`               |

## Getting Additional Help

### Azure Support

```bash
# Open support ticket (requires support plan)
az support tickets create \
  --ticket-name "My Issue" \
  --title "Cannot create VM" \
  --description "Detailed description..."
```

### Community Resources

- [Azure CLI GitHub Issues](https://github.com/Azure/azure-cli/issues)
- [Microsoft Q&A](https://docs.microsoft.com/en-us/answers/products/azure)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/azure-cli)

### Diagnostic Commands

```bash
# System info
az version --output json

# Account info
az account show --output json

# Network test
ping management.azure.com
curl -I https://management.azure.com

# Provider registration
az provider list --query "[].{Namespace:namespace, State:registrationState}" --output table
```

-----

**Pro Tip:** When seeking help, always include:

1. Azure CLI version (`az version`)
1. Error message (complete)
1. Command that failed
1. Expected vs actual behavior

Happy troubleshooting! 🔧
