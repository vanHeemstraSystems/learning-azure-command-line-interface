#!/bin/bash

# ============================================================================

# Azure CLI Basic Operations - Examples Script

# ============================================================================

# This script demonstrates common Azure CLI commands for learning purposes.

# DO NOT run this entire script at once - use individual commands as needed.

# Each section includes explanations and examples.

# ============================================================================

# Color codes for output

GREEN=’\033[0;32m’
BLUE=’\033[0;34m’
YELLOW=’\033[1;33m’
NC=’\033[0m’ # No Color

echo -e “${BLUE}========================================${NC}”
echo -e “${BLUE}Azure CLI Basic Operations - Examples${NC}”
echo -e “${BLUE}========================================${NC}\n”

# ============================================================================

# SECTION 1: Authentication & Account Management

# ============================================================================

echo -e “${GREEN}# 1. Authentication & Account Management${NC}\n”

# Login to Azure (opens browser for interactive authentication)

echo “az login”
echo “# Opens browser for interactive login\n”

# Login with specific tenant

echo “az login –tenant TENANT_ID”
echo “# Login to a specific tenant\n”

# Show current account information

echo “az account show”
echo “# Display currently active subscription\n”

# List all subscriptions

echo “az account list –output table”
echo “# List all subscriptions in a table format\n”

# Set active subscription

echo “az account set –subscription ‘SUBSCRIPTION_NAME_OR_ID’”
echo “# Switch to a different subscription\n”

# ============================================================================

# SECTION 2: Resource Groups

# ============================================================================

echo -e “\n${GREEN}# 2. Resource Groups${NC}\n”

# Create a resource group

echo “az group create –name learn-azure-rg –location eastus”
echo “# Create a new resource group named ‘learn-azure-rg’ in East US region\n”

# List all resource groups

echo “az group list –output table”
echo “# Display all resource groups in table format\n”

# Show details of a specific resource group

echo “az group show –name learn-azure-rg”
echo “# Get detailed information about a specific resource group\n”

# List resources in a resource group

echo “az resource list –resource-group learn-azure-rg –output table”
echo “# List all resources within a specific resource group\n”

# Update resource group tags

echo “az group update –name learn-azure-rg –tags Environment=Learning Project=AzureCLI”
echo “# Add or update tags on a resource group\n”

# Delete a resource group (WARNING: Deletes all resources!)

echo “az group delete –name learn-azure-rg –yes –no-wait”
echo “# Delete resource group and all resources (–yes skips confirmation, –no-wait runs in background)\n”

# ============================================================================

# SECTION 3: Storage Accounts

# ============================================================================

echo -e “\n${GREEN}# 3. Storage Accounts${NC}\n”

# Create a storage account

echo “az storage account create \”
echo “  –name learnazurestorage123 \”
echo “  –resource-group learn-azure-rg \”
echo “  –location eastus \”
echo “  –sku Standard_LRS”
echo “# Create storage account with locally-redundant storage (cheapest option)\n”

# List storage accounts

echo “az storage account list –output table”
echo “# List all storage accounts\n”

# Get storage account keys

echo “az storage account keys list \”
echo “  –account-name learnazurestorage123 \”
echo “  –resource-group learn-azure-rg”
echo “# Retrieve access keys for a storage account\n”

# Create a blob container

echo “az storage container create \”
echo “  –name mycontainer \”
echo “  –account-name learnazurestorage123”
echo “# Create a blob container in the storage account\n”

# Upload a file to blob storage

echo “az storage blob upload \”
echo “  –account-name learnazurestorage123 \”
echo “  –container-name mycontainer \”
echo “  –name myfile.txt \”
echo “  –file ./local/path/myfile.txt”
echo “# Upload a local file to blob storage\n”

# List blobs in container

echo “az storage blob list \”
echo “  –account-name learnazurestorage123 \”
echo “  –container-name mycontainer \”
echo “  –output table”
echo “# List all blobs in a container\n”

# Download a blob

echo “az storage blob download \”
echo “  –account-name learnazurestorage123 \”
echo “  –container-name mycontainer \”
echo “  –name myfile.txt \”
echo “  –file ./download/myfile.txt”
echo “# Download a blob to local file\n”

# ============================================================================

# SECTION 4: Virtual Machines

# ============================================================================

echo -e “\n${GREEN}# 4. Virtual Machines${NC}\n”

# Create a Linux VM

echo “az vm create \”
echo “  –resource-group learn-azure-rg \”
echo “  –name myLinuxVM \”
echo “  –image UbuntuLTS \”
echo “  –size Standard_B1s \”
echo “  –admin-username azureuser \”
echo “  –generate-ssh-keys”
echo “# Create an Ubuntu VM with SSH key authentication (takes ~3-5 minutes)\n”

# Create a Windows VM

echo “az vm create \”
echo “  –resource-group learn-azure-rg \”
echo “  –name myWindowsVM \”
echo “  –image Win2019Datacenter \”
echo “  –size Standard_B2s \”
echo “  –admin-username azureuser \”
echo “  –admin-password ‘SecurePassword123!’”
echo “# Create a Windows Server 2019 VM\n”

# List all VMs

echo “az vm list –output table”
echo “# List all virtual machines\n”

# List VMs with detailed information including power state

echo “az vm list –show-details –output table”
echo “# List VMs with detailed information including IP addresses and power state\n”

# Start a VM

echo “az vm start –name myLinuxVM –resource-group learn-azure-rg”
echo “# Start a stopped VM\n”

# Stop (deallocate) a VM

echo “az vm deallocate –name myLinuxVM –resource-group learn-azure-rg”
echo “# Stop and deallocate a VM (stops billing for compute)\n”

# Restart a VM

echo “az vm restart –name myLinuxVM –resource-group learn-azure-rg”
echo “# Restart a running VM\n”

# Get VM details

echo “az vm show –name myLinuxVM –resource-group learn-azure-rg”
echo “# Get detailed information about a specific VM\n”

# Delete a VM

echo “az vm delete –name myLinuxVM –resource-group learn-azure-rg –yes”
echo “# Delete a VM (–yes skips confirmation)\n”

# ============================================================================

# SECTION 5: Virtual Networks

# ============================================================================

echo -e “\n${GREEN}# 5. Virtual Networks${NC}\n”

# Create a virtual network

echo “az network vnet create \”
echo “  –resource-group learn-azure-rg \”
echo “  –name myVNet \”
echo “  –address-prefix 10.0.0.0/16 \”
echo “  –subnet-name mySubnet \”
echo “  –subnet-prefix 10.0.1.0/24”
echo “# Create a virtual network with one subnet\n”

# List virtual networks

echo “az network vnet list –output table”
echo “# List all virtual networks\n”

# Create a network security group

echo “az network nsg create \”
echo “  –resource-group learn-azure-rg \”
echo “  –name myNSG”
echo “# Create a network security group\n”

# Add NSG rule to allow SSH

echo “az network nsg rule create \”
echo “  –resource-group learn-azure-rg \”
echo “  –nsg-name myNSG \”
echo “  –name allow-ssh \”
echo “  –priority 1000 \”
echo “  –source-address-prefixes ‘*’ \”
echo “  –source-port-ranges ’*’ \”
echo “  –destination-address-prefixes ‘*’ \”
echo “  –destination-port-ranges 22 \”
echo “  –access Allow \”
echo “  –protocol Tcp”
echo “# Create NSG rule to allow SSH traffic on port 22\n”

# ============================================================================

# SECTION 6: Querying & Filtering

# ============================================================================

echo -e “\n${GREEN}# 6. Querying & Filtering${NC}\n”

# List all resources

echo “az resource list –output table”
echo “# List all resources in the subscription\n”

# Query resources by type

echo “az resource list \”
echo “  –resource-type ‘Microsoft.Compute/virtualMachines’ \”
echo “  –output table”
echo “# List only virtual machines\n”

# Query resources by location

echo “az resource list –location eastus –output table”
echo “# List resources in East US region\n”

# Query resources by tag

echo “az resource list –tag Environment=Production –output table”
echo “# List resources tagged with Environment=Production\n”

# Use JMESPath queries for custom output

echo “az vm list –query "[?powerState==‘VM running’].{Name:name, ResourceGroup:resourceGroup}" –output table”
echo “# List only running VMs showing just name and resource group\n”

# Get specific field from command output

echo “az storage account show –name learnazurestorage123 –query primaryEndpoints.blob”
echo “# Extract just the blob endpoint URL from storage account\n”

# ============================================================================

# SECTION 7: Output Formats

# ============================================================================

echo -e “\n${GREEN}# 7. Output Formats${NC}\n”

# Default JSON output

echo “az group list”
echo “# Output in JSON format (default)\n”

# Table format (human-readable)

echo “az group list –output table”
echo “# Output in table format\n”

# TSV format (for parsing)

echo “az group list –output tsv”
echo “# Output in tab-separated values\n”

# YAML format

echo “az group list –output yaml”
echo “# Output in YAML format\n”

# JSONc format (JSON with comments)

echo “az group list –output jsonc”
echo “# Output in JSON with color and formatting\n”

# ============================================================================

# SECTION 8: Configuration

# ============================================================================

echo -e “\n${GREEN}# 8. Configuration${NC}\n”

# Show current configuration

echo “az config get”
echo “# Display all configuration settings\n”

# Set default location

echo “az config set defaults.location=eastus”
echo “# Set East US as default location for all commands\n”

# Set default resource group

echo “az config set defaults.group=learn-azure-rg”
echo “# Set default resource group\n”

# Set default output format

echo “az config set core.output=table”
echo “# Set table as default output format\n”

# ============================================================================

# SECTION 9: Useful Tips & Tricks

# ============================================================================

echo -e “\n${GREEN}# 9. Useful Tips & Tricks${NC}\n”

# Get help for any command

echo “az vm create –help”
echo “# Show detailed help for a specific command\n”

# Find commands interactively

echo “az find ‘virtual machine’”
echo “# Search for commands related to virtual machines\n”

# Use interactive mode

echo “az interactive”
echo “# Start interactive mode with auto-completion and command suggestions\n”

# Validate templates without deploying

echo “az deployment group validate \”
echo “  –resource-group learn-azure-rg \”
echo “  –template-file template.json”
echo “# Validate ARM template without actually deploying it\n”

# Get version information

echo “az version”
echo “# Display Azure CLI version and installed extensions\n”

# ============================================================================

# SECTION 10: Cost Management

# ============================================================================

echo -e “\n${GREEN}# 10. Cost Management${NC}\n”

# List available VM sizes and their costs

echo “az vm list-sizes –location eastus –output table”
echo “# List available VM sizes in a region\n”

# Get pricing information (requires cost management extension)

echo “az consumption usage list \”
echo “  –start-date 2025-01-01 \”
echo “  –end-date 2025-01-31”
echo “# Get usage and cost data for a date range\n”

# Stop all VMs in a resource group (to save costs)

echo “az vm deallocate –ids $(az vm list –resource-group learn-azure-rg –query "[].id" -o tsv)”
echo “# Stop all VMs in a resource group at once\n”

# ============================================================================

# CLEANUP SECTION

# ============================================================================

echo -e “\n${YELLOW}# Cleanup Commands (Use with caution!)${NC}\n”

# Delete all resources in a resource group

echo “az group delete –name learn-azure-rg –yes –no-wait”
echo “# WARNING: This deletes everything in the resource group!\n”

# Delete all resource groups with a specific tag

echo “az group list –tag Environment=Learning –query "[].name" -o tsv | xargs -I {} az group delete –name {} –yes –no-wait”
echo “# WARNING: Batch delete all resource groups with a specific tag\n”

echo -e “\n${BLUE}========================================${NC}”
echo -e “${BLUE}End of Examples${NC}”
echo -e “${BLUE}========================================${NC}\n”

echo -e “${YELLOW}Remember:${NC}”
echo -e “  • Always clean up resources to avoid unexpected charges”
echo -e “  • Use –help flag to get detailed information about any command”
echo -e “  • Test commands with –dry-run when available”
echo -e “  • Use –output table for readable output during learning\n”
