#!/bin/bash

# ==============================================================================

# Azure Virtual Machine Deployment Script

# ==============================================================================

# This script demonstrates a complete VM deployment including:

# - Virtual network and subnet creation

# - Network Security Group (NSG) configuration

# - Public IP address creation

# - Network Interface Card (NIC) setup

# - VM creation with SSH key authentication

# - Disk management

# - VM lifecycle operations (start, stop, restart)

# ==============================================================================

set -e  # Exit on error

# Colors for output

readonly RED=’\033[0;31m’
readonly GREEN=’\033[0;32m’
readonly YELLOW=’\033[1;33m’
readonly BLUE=’\033[0;34m’
readonly NC=’\033[0m’ # No Color

# ==============================================================================

# CONFIGURATION

# ==============================================================================

readonly RESOURCE_GROUP=“vm-deployment-rg”
readonly LOCATION=“eastus”
readonly VM_NAME=“demo-vm”
readonly VNET_NAME=“demo-vnet”
readonly SUBNET_NAME=“demo-subnet”
readonly NSG_NAME=“demo-nsg”
readonly PUBLIC_IP_NAME=“demo-public-ip”
readonly NIC_NAME=“demo-nic”
readonly ADMIN_USERNAME=“azureuser”
readonly VM_SIZE=“Standard_B1s”  # Cheapest option for demo
readonly VM_IMAGE=“UbuntuLTS”

# ==============================================================================

# HELPER FUNCTIONS

# ==============================================================================

log() {
echo -e “${GREEN}[INFO]${NC} $*”
}

warn() {
echo -e “${YELLOW}[WARN]${NC} $*”
}

error() {
echo -e “${RED}[ERROR]${NC} $*” >&2
exit 1
}

section() {
echo -e “\n${BLUE}========================================${NC}”
echo -e “${BLUE}$*${NC}”
echo -e “${BLUE}========================================${NC}\n”
}

# ==============================================================================

# PREREQUISITE CHECKS

# ==============================================================================

check_prerequisites() {
log “Checking prerequisites…”

```
# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    error "Azure CLI is not installed. Please install it first."
fi

# Check if logged in
if ! az account show &> /dev/null; then
    error "Not logged in to Azure. Please run 'az login' first."
fi

log "Prerequisites check passed!"
```

}

# ==============================================================================

# RESOURCE GROUP

# ==============================================================================

create_resource_group() {
section “Creating Resource Group”

```
log "Creating resource group: $RESOURCE_GROUP in $LOCATION"

az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --tags \
        Environment=Demo \
        Purpose=VMDeployment \
        CostCenter=Learning \
        CreatedBy=Script \
    --output table

log "Resource group created successfully!"
```

}

# ==============================================================================

# NETWORKING

# ==============================================================================

create_virtual_network() {
section “Creating Virtual Network”

```
log "Creating virtual network: $VNET_NAME"
log "Address space: 10.0.0.0/16"

az network vnet create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VNET_NAME" \
    --address-prefix 10.0.0.0/16 \
    --subnet-name "$SUBNET_NAME" \
    --subnet-prefix 10.0.1.0/24 \
    --location "$LOCATION" \
    --output table

log "Virtual network created successfully!"

log "\nVirtual network details:"
az network vnet show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VNET_NAME" \
    --query "{Name:name, AddressSpace:addressSpace.addressPrefixes[0], Location:location}" \
    --output table
```

}

create_network_security_group() {
section “Creating Network Security Group”

```
log "Creating NSG: $NSG_NAME"

az network nsg create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$NSG_NAME" \
    --location "$LOCATION" \
    --output table

log "NSG created successfully!"

# Add rule to allow SSH (port 22)
log "\nAdding SSH rule to NSG..."
az network nsg rule create \
    --resource-group "$RESOURCE_GROUP" \
    --nsg-name "$NSG_NAME" \
    --name AllowSSH \
    --priority 1000 \
    --source-address-prefixes '*' \
    --source-port-ranges '*' \
    --destination-address-prefixes '*' \
    --destination-port-ranges 22 \
    --access Allow \
    --protocol Tcp \
    --description "Allow SSH access" \
    --output table

# Add rule to allow HTTP (port 80)
log "Adding HTTP rule to NSG..."
az network nsg rule create \
    --resource-group "$RESOURCE_GROUP" \
    --nsg-name "$NSG_NAME" \
    --name AllowHTTP \
    --priority 1001 \
    --source-address-prefixes '*' \
    --source-port-ranges '*' \
    --destination-address-prefixes '*' \
    --destination-port-ranges 80 \
    --access Allow \
    --protocol Tcp \
    --description "Allow HTTP access" \
    --output table

# Add rule to allow HTTPS (port 443)
log "Adding HTTPS rule to NSG..."
az network nsg rule create \
    --resource-group "$RESOURCE_GROUP" \
    --nsg-name "$NSG_NAME" \
    --name AllowHTTPS \
    --priority 1002 \
    --source-address-prefixes '*' \
    --source-port-ranges '*' \
    --destination-address-prefixes '*' \
    --destination-port-ranges 443 \
    --access Allow \
    --protocol Tcp \
    --description "Allow HTTPS access" \
    --output table

log "\nNSG rules configured successfully!"

log "\nListing all NSG rules:"
az network nsg rule list \
    --resource-group "$RESOURCE_GROUP" \
    --nsg-name "$NSG_NAME" \
    --query "[].{Name:name, Priority:priority, Port:destinationPortRange, Access:access}" \
    --output table
```

}

create_public_ip() {
section “Creating Public IP Address”

```
log "Creating public IP: $PUBLIC_IP_NAME"

az network public-ip create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$PUBLIC_IP_NAME" \
    --sku Basic \
    --allocation-method Dynamic \
    --version IPv4 \
    --output table

log "Public IP created successfully!"
```

}

create_network_interface() {
section “Creating Network Interface”

```
log "Creating NIC: $NIC_NAME"

az network nic create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$NIC_NAME" \
    --vnet-name "$VNET_NAME" \
    --subnet "$SUBNET_NAME" \
    --network-security-group "$NSG_NAME" \
    --public-ip-address "$PUBLIC_IP_NAME" \
    --output table

log "Network interface created successfully!"

log "\nNIC details:"
az network nic show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$NIC_NAME" \
    --query "{Name:name, MacAddress:macAddress, PrivateIP:ipConfigurations[0].privateIpAddress}" \
    --output table
```

}

# ==============================================================================

# VIRTUAL MACHINE

# ==============================================================================

create_virtual_machine() {
section “Creating Virtual Machine”

```
log "Creating VM: $VM_NAME"
log "Image: $VM_IMAGE"
log "Size: $VM_SIZE"
log "Admin user: $ADMIN_USERNAME"
log "\nThis will take 3-5 minutes..."

# Generate SSH keys if they don't exist
if [ ! -f ~/.ssh/id_rsa ]; then
    log "Generating SSH keys..."
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
fi

az vm create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    --location "$LOCATION" \
    --nics "$NIC_NAME" \
    --image "$VM_IMAGE" \
    --size "$VM_SIZE" \
    --admin-username "$ADMIN_USERNAME" \
    --ssh-key-values ~/.ssh/id_rsa.pub \
    --os-disk-name "${VM_NAME}-osdisk" \
    --os-disk-size-gb 30 \
    --tags \
        Environment=Demo \
        Owner=Learning \
        Application=Demo \
    --output json > /tmp/vm-creation-output.json

log "Virtual machine created successfully!"

# Extract and display important information
PUBLIC_IP=$(az network public-ip show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$PUBLIC_IP_NAME" \
    --query ipAddress \
    --output tsv)

PRIVATE_IP=$(az vm show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    --show-details \
    --query privateIps \
    --output tsv)

section "VM Connection Information"
echo -e "${GREEN}VM Name:${NC} $VM_NAME"
echo -e "${GREEN}Public IP:${NC} $PUBLIC_IP"
echo -e "${GREEN}Private IP:${NC} $PRIVATE_IP"
echo -e "${GREEN}Username:${NC} $ADMIN_USERNAME"
echo -e "\n${YELLOW}SSH Command:${NC}"
echo -e "ssh $ADMIN_USERNAME@$PUBLIC_IP"
```

}

show_vm_details() {
section “Virtual Machine Details”

```
log "Fetching VM information..."

az vm show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    --show-details \
    --query "{Name:name, OS:storageProfile.osDisk.osType, Size:hardwareProfile.vmSize, State:powerState, Location:location, ResourceGroup:resourceGroup}" \
    --output table

log "\nFetching VM sizes available in region..."
log "Showing similar-sized VMs for comparison:"
az vm list-sizes \
    --location "$LOCATION" \
    --query "[?contains(name, 'Standard_B')].{Name:name, vCPUs:numberOfCores, MemoryGB:memoryInMb, DiskGB:resourceDiskSizeInMb}" \
    --output table | head -10
```

}

# ==============================================================================

# VM OPERATIONS

# ==============================================================================

install_web_server() {
section “Installing Web Server on VM”

```
log "Installing nginx web server..."
log "This demonstrates running commands on the VM..."

# Run command on VM
az vm run-command invoke \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    --command-id RunShellScript \
    --scripts \
        "sudo apt-get update" \
        "sudo apt-get install -y nginx" \
        "echo '<h1>Hello from Azure VM!</h1><p>This is a demo VM created with Azure CLI.</p>' | sudo tee /var/www/html/index.html" \
    --output table

PUBLIC_IP=$(az network public-ip show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$PUBLIC_IP_NAME" \
    --query ipAddress \
    --output tsv)

log "\nWeb server installed successfully!"
log "Access the web server at: http://$PUBLIC_IP"
warn "Note: It may take a minute for the web server to be accessible"
```

}

stop_vm() {
section “Stopping Virtual Machine”

```
log "Stopping (deallocating) VM: $VM_NAME"
log "This will stop compute charges..."

az vm deallocate \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    --output table

log "VM stopped successfully!"

# Show current status
STATUS=$(az vm get-instance-view \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    --query "instanceView.statuses[?starts_with(code, 'PowerState/')].displayStatus" \
    --output tsv)

log "Current VM status: $STATUS"
```

}

start_vm() {
section “Starting Virtual Machine”

```
log "Starting VM: $VM_NAME"

az vm start \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    --output table

log "VM started successfully!"

# Show current status
STATUS=$(az vm get-instance-view \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    --query "instanceView.statuses[?starts_with(code, 'PowerState/')].displayStatus" \
    --output tsv)

log "Current VM status: $STATUS"
```

}

restart_vm() {
section “Restarting Virtual Machine”

```
log "Restarting VM: $VM_NAME"

az vm restart \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    --output table

log "VM restarted successfully!"
```

}

# ==============================================================================

# DISK OPERATIONS

# ==============================================================================

create_data_disk() {
section “Creating and Attaching Data Disk”

```
local DISK_NAME="${VM_NAME}-datadisk"

log "Creating data disk: $DISK_NAME"
log "Size: 10 GB"

# Create managed disk
az disk create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$DISK_NAME" \
    --size-gb 10 \
    --sku Standard_LRS \
    --output table

log "Data disk created successfully!"

log "\nAttaching disk to VM..."
az vm disk attach \
    --resource-group "$RESOURCE_GROUP" \
    --vm-name "$VM_NAME" \
    --name "$DISK_NAME" \
    --output table

log "Data disk attached successfully!"

log "\nTo use the disk, SSH into the VM and run:"
echo "  sudo fdisk -l                    # List disks"
echo "  sudo mkfs.ext4 /dev/sdc          # Format disk"
echo "  sudo mkdir /mnt/data             # Create mount point"
echo "  sudo mount /dev/sdc /mnt/data    # Mount disk"
```

}

list_vm_disks() {
section “Listing VM Disks”

```
log "Fetching disk information..."

az vm show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    --query "{OSdisk:storageProfile.osDisk.name, DataDisks:storageProfile.dataDisks[].name}" \
    --output json
```

}

# ==============================================================================

# MONITORING

# ==============================================================================

show_vm_metrics() {
section “Virtual Machine Metrics”

```
log "Fetching available metrics..."

VM_ID=$(az vm show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    --query id \
    --output tsv)

log "\nAvailable metrics for this VM:"
az monitor metrics list-definitions \
    --resource "$VM_ID" \
    --query "[].{Metric:name.value, Unit:unit}" \
    --output table | head -20

log "\nNote: Metric data collection may take a few minutes after VM creation"
```

}

# ==============================================================================

# BACKUP & SNAPSHOT

# ==============================================================================

create_vm_snapshot() {
section “Creating VM Snapshot”

```
local SNAPSHOT_NAME="${VM_NAME}-snapshot-$(date +%Y%m%d-%H%M%S)"

log "Creating snapshot: $SNAPSHOT_NAME"

# Get OS disk name
OS_DISK_NAME=$(az vm show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    --query storageProfile.osDisk.name \
    --output tsv)

log "OS Disk: $OS_DISK_NAME"

# Get OS disk ID
OS_DISK_ID=$(az disk show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$OS_DISK_NAME" \
    --query id \
    --output tsv)

# Create snapshot
az snapshot create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$SNAPSHOT_NAME" \
    --source "$OS_DISK_ID" \
    --output table

log "Snapshot created successfully!"
log "Snapshot name: $SNAPSHOT_NAME"
```

}

# ==============================================================================

# COST INFORMATION

# ==============================================================================

show_cost_information() {
section “Cost Information”

```
log "Estimated monthly costs (approximate):"
echo ""
echo "VM Size: $VM_SIZE"
echo "  • Compute: ~\$10-15/month (when running)"
echo "  • Storage (OS Disk): ~\$2-3/month"
echo "  • Public IP: ~\$3-4/month"
echo "  • Data transfer: Variable"
echo ""
warn "Total estimated cost: ~\$15-25/month"
warn "Note: Costs stop for compute when VM is deallocated (stopped)"
echo ""
log "To minimize costs:"
echo "  1. Deallocate VM when not in use: az vm deallocate"
echo "  2. Delete resources when done: az group delete"
echo "  3. Use auto-shutdown schedules"
echo "  4. Monitor usage with Azure Cost Management"
```

}

# ==============================================================================

# CLEANUP

# ==============================================================================

cleanup() {
section “Cleanup”

```
read -p "Do you want to delete all created resources? (yes/no): " -r
if [[ $REPLY =~ ^[Yy]es$ ]]; then
    warn "Deleting resource group and all resources..."
    
    az group delete \
        --name "$RESOURCE_GROUP" \
        --yes \
        --no-wait
    
    log "Deletion initiated (running in background)"
    log "Resource group '$RESOURCE_GROUP' and all resources will be deleted"
    log "This includes:"
    log "  - Virtual Machine: $VM_NAME"
    log "  - Virtual Network: $VNET_NAME"
    log "  - NSG: $NSG_NAME"
    log "  - Public IP: $PUBLIC_IP_NAME"
    log "  - Network Interface: $NIC_NAME"
    log "  - All associated disks"
else
    log "Skipping cleanup."
    warn "\n⚠️  Remember to delete resources manually to avoid charges:"
    echo "az group delete --name $RESOURCE_GROUP --yes"
    echo ""
    warn "Or stop the VM to reduce charges:"
    echo "az vm deallocate --resource-group $RESOURCE_GROUP --name $VM_NAME"
fi
```

}

# ==============================================================================

# INTERACTIVE OPERATIONS MENU

# ==============================================================================

operations_menu() {
section “VM Operations Menu”

```
while true; do
    echo ""
    echo "Available operations:"
    echo "1. Show VM details"
    echo "2. Stop VM (deallocate)"
    echo "3. Start VM"
    echo "4. Restart VM"
    echo "5. Install web server"
    echo "6. Create data disk"
    echo "7. List VM disks"
    echo "8. Create VM snapshot"
    echo "9. Show available metrics"
    echo "10. Continue to cleanup"
    echo ""
    read -p "Select an option (1-10): " -r OPTION
    
    case $OPTION in
        1) show_vm_details ;;
        2) stop_vm ;;
        3) start_vm ;;
        4) restart_vm ;;
        5) install_web_server ;;
        6) create_data_disk ;;
        7) list_vm_disks ;;
        8) create_vm_snapshot ;;
        9) show_vm_metrics ;;
        10) break ;;
        *) warn "Invalid option. Please select 1-10." ;;
    esac
    
    read -p "Press Enter to continue..."
done
```

}

# ==============================================================================

# MAIN EXECUTION

# ==============================================================================

main() {
section “Azure Virtual Machine Deployment”
log “This script demonstrates complete VM deployment with networking”
log “Resource Group: $RESOURCE_GROUP”
log “VM Name: $VM_NAME”
log “Location: $LOCATION”
log “VM Size: $VM_SIZE (cheapest option for demo)”

```
# Check prerequisites
check_prerequisites

# Create infrastructure
create_resource_group
create_virtual_network
create_network_security_group
create_public_ip
create_network_interface

# Create VM
create_virtual_machine
show_vm_details

# Show cost information
show_cost_information

# Success message
section "Deployment Completed Successfully!"
log "Virtual machine is now running!"

PUBLIC_IP=$(az network public-ip show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$PUBLIC_IP_NAME" \
    --query ipAddress \
    --output tsv 2>/dev/null || echo "Not yet assigned")

log "\nQuick access commands:"
echo "  SSH: ssh $ADMIN_USERNAME@$PUBLIC_IP"
echo "  Stop VM: az vm deallocate --resource-group $RESOURCE_GROUP --name $VM_NAME"
echo "  Start VM: az vm start --resource-group $RESOURCE_GROUP --name $VM_NAME"

warn "\n⚠️  IMPORTANT: This VM will incur costs while running!"

# Interactive operations menu
echo ""
read -p "Would you like to perform additional operations? (yes/no): " -r
if [[ $REPLY =~ ^[Yy]es$ ]]; then
    operations_menu
fi

# Cleanup prompt
echo ""
cleanup
```

}

# Run main function

main “$@”
