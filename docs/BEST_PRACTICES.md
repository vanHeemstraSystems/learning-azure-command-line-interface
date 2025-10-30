# Azure CLI Best Practices

A comprehensive guide to using Azure CLI effectively, securely, and efficiently in production environments.

## Table of Contents

1. [Naming Conventions](#naming-conventions)
1. [Security Best Practices](#security-best-practices)
1. [Resource Management](#resource-management)
1. [Cost Optimization](#cost-optimization)
1. [Scripting Best Practices](#scripting-best-practices)
1. [Error Handling](#error-handling)
1. [Performance Optimization](#performance-optimization)
1. [CI/CD Integration](#cicd-integration)
1. [Idempotency](#idempotency)
1. [Monitoring and Logging](#monitoring-and-logging)

## Naming Conventions

Consistent naming is crucial for resource organization and management.

### General Principles

1. **Be descriptive and consistent**
1. **Use lowercase for resource names** (where allowed)
1. **Include environment indicators** (dev, test, prod)
1. **Include purpose/function**
1. **Keep within Azure limits** (most resources: 1-63 characters)

### Recommended Patterns

**Resource Groups:**

```
<company>-<project>-<environment>-<region>-rg

Examples:
acme-webapp-prod-eastus-rg
acme-api-dev-westus-rg
contoso-data-staging-centralus-rg
```

**Storage Accounts:**

```
<company><project><environment><purpose><random>

Examples:
acmewebappprodstorage01
contosoapidevlogs123
mycompanydatabackup456

Note: Storage accounts must be:
- Globally unique
- 3-24 characters
- Lowercase letters and numbers only
- No hyphens or special characters
```

**Virtual Machines:**

```
<project>-<environment>-<purpose>-<instance>

Examples:
webapp-prod-frontend-01
api-dev-backend-02
data-staging-processor-01
```

**Virtual Networks:**

```
<project>-<environment>-vnet-<region>

Examples:
webapp-prod-vnet-eastus
api-dev-vnet-westus
```

### Naming Script Example

```bash
#!/bin/bash

# Define naming variables
COMPANY="acme"
PROJECT="webapp"
ENVIRONMENT="prod"
REGION="eastus"

# Generate names
RG_NAME="${COMPANY}-${PROJECT}-${ENVIRONMENT}-${REGION}-rg"
VNET_NAME="${PROJECT}-${ENVIRONMENT}-vnet-${REGION}"
VM_NAME="${PROJECT}-${ENVIRONMENT}-frontend-01"

# Use in commands
az group create --name $RG_NAME --location $REGION
az network vnet create --name $VNET_NAME --resource-group $RG_NAME
```

### Naming Restrictions by Resource Type

|Resource Type  |Max Length         |Allowed Characters                                   |Case Sensitive           |
|---------------|-------------------|-----------------------------------------------------|-------------------------|
|Resource Group |90                 |Alphanumeric, underscore, parentheses, hyphen, period|No                       |
|Storage Account|3-24               |Lowercase letters and numbers                        |No                       |
|Virtual Machine|64 (15 for Windows)|Alphanumeric and hyphen                              |Yes (Linux), No (Windows)|
|Virtual Network|64                 |Alphanumeric, underscore, hyphen, period             |No                       |
|Key Vault      |3-24               |Alphanumeric and hyphen                              |No                       |

## Security Best Practices

### 1. Authentication

**DO:**

```bash
# Use managed identities for Azure resources
az login --identity

# Use service principals for automation
az login --service-principal \
  --username $SP_ID \
  --password $SP_SECRET \
  --tenant $TENANT_ID
```

**DON’T:**

```bash
# Never store credentials in scripts
PASSWORD="MySecretPassword123!"  # ❌ BAD

# Never commit credentials to Git
az login --username user@domain.com --password "SecretPass123"  # ❌ BAD
```

### 2. Secret Management

**Use Azure Key Vault:**

```bash
# Store secrets in Key Vault
az keyvault secret set \
  --vault-name myKeyVault \
  --name "DatabasePassword" \
  --value "SuperSecretPassword123!"

# Retrieve secrets in scripts
DB_PASSWORD=$(az keyvault secret show \
  --vault-name myKeyVault \
  --name "DatabasePassword" \
  --query value --output tsv)

# Use in commands (never echo!)
az sql server create --admin-password $DB_PASSWORD ...
```

**Environment Variables:**

```bash
# Store in environment (not in script)
export AZURE_STORAGE_ACCOUNT="mystorageaccount"
export AZURE_STORAGE_KEY=$(az storage account keys list \
  --account-name mystorageaccount \
  --query "[0].value" --output tsv)

# Reference in commands
az storage blob upload --file myfile.txt ...
```

### 3. Access Control

**Principle of Least Privilege:**

```bash
# Assign minimum required role
az role assignment create \
  --assignee user@domain.com \
  --role "Reader" \
  --scope "/subscriptions/{subscription-id}/resourceGroups/myRG"

# Common roles (least to most privileged):
# - Reader: View only
# - Contributor: Manage resources (no access control)
# - Owner: Full control
```

**Avoid using Owner role:**

```bash
# ❌ BAD: Too much privilege
az role assignment create --role "Owner" ...

# ✅ GOOD: Specific role
az role assignment create --role "Virtual Machine Contributor" ...
```

### 4. Network Security

```bash
# Always configure Network Security Groups
az network nsg create --name myNSG --resource-group myRG

# Restrict inbound access
az network nsg rule create \
  --nsg-name myNSG \
  --resource-group myRG \
  --name AllowSSH \
  --priority 1000 \
  --source-address-prefixes "203.0.113.0/24" \  # Specific IP range
  --destination-port-ranges 22 \
  --access Allow \
  --protocol Tcp

# Never allow all traffic from internet
# ❌ BAD
az network nsg rule create --source-address-prefixes "*" ...
```

### 5. Encryption

```bash
# Enable encryption at rest for storage
az storage account create \
  --encryption-services blob file \
  --https-only true

# Enable disk encryption for VMs
az vm encryption enable \
  --resource-group myRG \
  --name myVM \
  --disk-encryption-keyvault myKeyVault
```

## Resource Management

### 1. Tagging Strategy

**Always tag resources:**

```bash
# Comprehensive tagging
az group create \
  --name myRG \
  --location eastus \
  --tags \
    Environment=Production \
    CostCenter=IT-123 \
    Owner=john.doe@company.com \
    Project=WebApp \
    CreatedDate=$(date +%Y-%m-%d) \
    ManagedBy=Terraform

# Apply tags to existing resources
az resource tag \
  --tags Environment=Production CostCenter=IT-123 \
  --ids $(az resource list --query "[].id" --output tsv)
```

**Standard Tag Schema:**

```bash
# Required tags
Environment     # dev, staging, prod
CostCenter      # Finance tracking
Owner           # Contact email
Project         # Project name

# Optional tags
CreatedDate     # YYYY-MM-DD
ManagedBy       # IaC tool (ARM, Terraform, etc.)
Department      # Business unit
Application     # Application name
Backup          # Backup policy
DataClass       # Confidential, Internal, Public
```

### 2. Resource Groups

**Organization principles:**

```bash
# ✅ GOOD: Group by lifecycle
az group create --name webapp-prod-frontend-rg --location eastus
az group create --name webapp-prod-backend-rg --location eastus
az group create --name webapp-prod-data-rg --location eastus

# ❌ BAD: Mixing lifecycles
az group create --name all-prod-resources-rg  # Too broad
```

**Deletion strategy:**

```bash
# Resource groups enable easy cleanup
# Delete entire application stack
az group delete --name webapp-dev-rg --yes --no-wait

# Use --no-wait for faster operations
# Monitor progress separately
az group wait --name webapp-dev-rg --deleted
```

### 3. Resource Locks

**Prevent accidental deletion:**

```bash
# Lock production resource group
az lock create \
  --name preventDeletion \
  --resource-group webapp-prod-rg \
  --lock-type CanNotDelete \
  --notes "Production environment - do not delete"

# Lock specific resource
az lock create \
  --name preventDeletion \
  --resource-type Microsoft.Storage/storageAccounts \
  --resource-name prodstorageaccount \
  --resource-group webapp-prod-rg \
  --lock-type CanNotDelete

# List locks
az lock list --output table

# Remove lock (when needed)
az lock delete --name preventDeletion --resource-group webapp-prod-rg
```

## Cost Optimization

### 1. Right-Sizing Resources

```bash
# Start with smaller VM sizes
az vm create \
  --size Standard_B1s \  # Cheapest option for testing
  --resource-group myRG \
  --name myVM

# Common cost-effective sizes:
# Standard_B1s    - 1 vCPU, 1 GB RAM  (cheapest)
# Standard_B2s    - 2 vCPU, 4 GB RAM
# Standard_B1ms   - 1 vCPU, 2 GB RAM

# Monitor and resize as needed
az vm resize \
  --resource-group myRG \
  --name myVM \
  --size Standard_B2s
```

### 2. Deallocate Resources When Not in Use

```bash
# Stop (deallocate) VMs to stop compute charges
az vm deallocate --resource-group myRG --name myVM

# Start when needed
az vm start --resource-group myRG --name myVM

# Automate with scripts
# Stop all dev VMs at night
az vm list --resource-group dev-rg --query "[].id" --output tsv | \
  xargs -I {} az vm deallocate --ids {}
```

### 3. Delete Unused Resources

```bash
# Find unattached disks (cost money)
az disk list --query "[?diskState=='Unattached'].{Name:name, ResourceGroup:resourceGroup}" --output table

# Delete unattached disks
az disk delete --name unused-disk --resource-group myRG --yes

# Find orphaned resources
az resource list --query "[?contains(name, 'orphan')]"
```

### 4. Use Appropriate Storage Tiers

```bash
# Use appropriate SKU
az storage account create \
  --sku Standard_LRS \  # Cheapest, local redundancy
  --resource-group myRG

# Storage SKUs by cost (cheap to expensive):
# Standard_LRS  - Locally redundant
# Standard_GRS  - Geo-redundant
# Premium_LRS   - Premium, locally redundant
```

### 5. Enable Auto-Shutdown for VMs

```bash
# Create auto-shutdown schedule
az vm auto-shutdown \
  --resource-group myRG \
  --name myVM \
  --time 1900 \
  --timezone "Pacific Standard Time"
```

### 6. Monitor Costs

```bash
# Set up cost alerts (requires Cost Management)
az consumption budget create \
  --resource-group myRG \
  --budget-name monthly-budget \
  --amount 100 \
  --category Cost \
  --time-grain Monthly \
  --time-period start-date=2025-01-01 end-date=2025-12-31
```

## Scripting Best Practices

### 1. Script Structure

```bash
#!/bin/bash
set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Script: deploy-webapp.sh
# Description: Deploy web application infrastructure
# Author: Your Name
# Date: 2025-01-01

# ==============================================================================
# CONFIGURATION
# ==============================================================================

readonly RESOURCE_GROUP="webapp-prod-rg"
readonly LOCATION="eastus"
readonly TIMESTAMP=$(date +%Y%m%d-%H%M%S)
readonly LOG_FILE="deploy-${TIMESTAMP}.log"

# ==============================================================================
# FUNCTIONS
# ==============================================================================

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

error() {
    echo "[ERROR] $*" >&2
    exit 1
}

create_resource_group() {
    log "Creating resource group: $RESOURCE_GROUP"
    az group create \
        --name "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --tags Environment=Production CreatedDate=$(date +%Y-%m-%d) \
        || error "Failed to create resource group"
}

# ==============================================================================
# MAIN
# ==============================================================================

main() {
    log "Starting deployment..."
    
    # Check prerequisites
    command -v az >/dev/null 2>&1 || error "Azure CLI not found"
    
    # Verify authentication
    az account show &>/dev/null || error "Not logged in to Azure"
    
    # Execute deployment
    create_resource_group
    
    log "Deployment completed successfully"
}

main "$@"
```

### 2. Error Handling

```bash
# Always check command success
if az group create --name myRG --location eastus; then
    echo "Success!"
else
    echo "Failed to create resource group" >&2
    exit 1
fi

# Use set -e for automatic error handling
set -e  # Exit immediately if command fails

# Capture command output
if OUTPUT=$(az group create --name myRG --location eastus 2>&1); then
    echo "Created: $OUTPUT"
else
    echo "Failed: $OUTPUT" >&2
    exit 1
fi

# Check resource existence before creating
if az group show --name myRG &>/dev/null; then
    echo "Resource group already exists"
else
    az group create --name myRG --location eastus
fi
```

### 3. Parameterization

```bash
#!/bin/bash

# Accept command-line arguments
RESOURCE_GROUP="${1:-default-rg}"
LOCATION="${2:-eastus}"

# Validate parameters
if [[ -z "$RESOURCE_GROUP" ]]; then
    echo "Usage: $0 <resource-group> [location]" >&2
    exit 1
fi

# Use parameters
az group create --name "$RESOURCE_GROUP" --location "$LOCATION"
```

### 4. Parallel Execution

```bash
# Sequential (slow)
az vm create --name vm1 ... &
az vm create --name vm2 ... &
az vm create --name vm3 ... &
wait  # Wait for all background jobs

# Using xargs for parallel execution
echo -e "vm1\nvm2\nvm3" | xargs -P 3 -I {} \
  az vm create --name {} --resource-group myRG --image UbuntuLTS
```

## Idempotency

**Make scripts safe to run multiple times:**

```bash
# ❌ BAD: Fails on second run
az group create --name myRG --location eastus

# ✅ GOOD: Check first
if ! az group show --name myRG &>/dev/null; then
    az group create --name myRG --location eastus
fi

# ✅ GOOD: Use --no-fail-on-exist (where available)
# Note: Not all commands support this

# ✅ BETTER: Function for idempotent operations
create_if_not_exists() {
    local RG=$1
    local LOCATION=$2
    
    if az group show --name "$RG" &>/dev/null; then
        echo "Resource group $RG already exists"
        return 0
    fi
    
    az group create --name "$RG" --location "$LOCATION"
}
```

## Performance Optimization

### 1. Batch Operations

```bash
# ❌ SLOW: Individual commands
for vm in vm1 vm2 vm3; do
    az vm start --name $vm --resource-group myRG
done

# ✅ FAST: Batch with IDs
az vm start --ids $(az vm list --resource-group myRG --query "[].id" --output tsv)
```

### 2. Reduce API Calls

```bash
# ❌ SLOW: Multiple show commands
NAME=$(az vm show --name myVM --resource-group myRG --query name --output tsv)
SIZE=$(az vm show --name myVM --resource-group myRG --query hardwareProfile.vmSize --output tsv)
LOCATION=$(az vm show --name myVM --resource-group myRG --query location --output tsv)

# ✅ FAST: Single call with query
VM_INFO=$(az vm show --name myVM --resource-group myRG --query "{Name:name, Size:hardwareProfile.vmSize, Location:location}" --output json)
```

### 3. Use –no-wait

```bash
# For long-running operations
az vm create --name myVM --resource-group myRG --image UbuntuLTS --no-wait

# Continue with other tasks
# ...

# Check status later
az vm wait --name myVM --resource-group myRG --created
```

## CI/CD Integration

### 1. Service Principal Setup

```bash
# Create service principal for CI/CD
SP=$(az ad sp create-for-rbac \
    --name "cicd-pipeline" \
    --role Contributor \
    --scopes /subscriptions/{subscription-id}/resourceGroups/myRG)

# Extract credentials (store in CI/CD secrets)
echo $SP | jq -r '.appId'      # Client ID
echo $SP | jq -r '.password'   # Client Secret
echo $SP | jq -r '.tenant'     # Tenant ID
```

### 2. Azure DevOps Pipeline

```yaml
# azure-pipelines.yml
trigger:
  - main

pool:
  vmImage: 'ubuntu-latest'

variables:
  azureSubscription: 'MyAzureConnection'
  resourceGroup: 'webapp-prod-rg'

steps:
- task: AzureCLI@2
  displayName: 'Deploy Infrastructure'
  inputs:
    azureSubscription: $(azureSubscription)
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    inlineScript: |
      az group create --name $(resourceGroup) --location eastus
      az vm create --resource-group $(resourceGroup) --name myVM --image UbuntuLTS
```

### 3. GitHub Actions

```yaml
# .github/workflows/deploy.yml
name: Deploy to Azure

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}
      
      - name: Create Resource Group
        run: |
          az group create \
            --name webapp-prod-rg \
            --location eastus
```

## Common Anti-Patterns to Avoid

### ❌ DON’T:

1. **Hardcode values in scripts**

```bash
az group create --name my-hardcoded-rg --location eastus  # Bad
```

1. **Ignore errors**

```bash
az group create ... || true  # Bad: Silences failures
```

1. **Store secrets in code**

```bash
PASSWORD="mypassword123"  # Bad: Security risk
```

1. **Use overly broad permissions**

```bash
az role assignment create --role Owner ...  # Bad: Too much access
```

1. **Create resources without tags**

```bash
az group create --name myRG  # Bad: No tags for tracking
```

### ✅ DO:

1. **Parameterize everything**
1. **Handle errors explicitly**
1. **Use Key Vault for secrets**
1. **Apply principle of least privilege**
1. **Tag all resources**

## Quick Checklist

Before running any Azure CLI script:

- [ ] Authenticated to correct subscription?
- [ ] Using appropriate permissions?
- [ ] Resources properly named?
- [ ] Tags applied?
- [ ] Error handling in place?
- [ ] Secrets stored securely?
- [ ] Cost impact considered?
- [ ] Tested in dev environment?
- [ ] Can run idempotently?
- [ ] Logging enabled?

## Additional Resources

- [Azure Architecture Center](https://docs.microsoft.com/en-us/azure/architecture/)
- [Azure Naming Conventions](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging)
- [Azure Security Best Practices](https://docs.microsoft.com/en-us/azure/security/fundamentals/best-practices-and-patterns)
- [Cost Optimization](https://docs.microsoft.com/en-us/azure/cost-management-billing/costs/cost-mgt-best-practices)

-----

Following these best practices will help you build reliable, secure, and cost-effective Azure infrastructure! 🚀
