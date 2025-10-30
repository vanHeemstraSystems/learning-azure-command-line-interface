#!/bin/bash

# ==============================================================================

# Azure Storage Account Demo Script

# ==============================================================================

# This script demonstrates comprehensive Azure Storage operations including:

# - Storage account creation with various SKUs

# - Blob container management

# - File upload/download operations

# - Access key management

# - SAS token generation

# - Lifecycle management policies

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

# Generate unique suffix for globally unique names

readonly UNIQUE_SUFFIX=$(date +%s)
readonly RESOURCE_GROUP=“storage-demo-rg”
readonly LOCATION=“eastus”
readonly STORAGE_ACCOUNT=“storagedemo${UNIQUE_SUFFIX}”
readonly CONTAINER_NAME=“democontainer”
readonly FILE_SHARE_NAME=“demofileshare”
readonly QUEUE_NAME=“demoqueue”
readonly TABLE_NAME=“demotable”

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

# RESOURCE GROUP OPERATIONS

# ==============================================================================

create_resource_group() {
section “Creating Resource Group”

```
log "Creating resource group: $RESOURCE_GROUP in $LOCATION"

az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --tags Environment=Demo Purpose=StorageDemo CreatedBy=Script \
    --output table

log "Resource group created successfully!"
```

}

# ==============================================================================

# STORAGE ACCOUNT OPERATIONS

# ==============================================================================

create_storage_account() {
section “Creating Storage Account”

```
log "Creating storage account: $STORAGE_ACCOUNT"
log "SKU: Standard_LRS (Locally Redundant Storage)"
log "This may take a minute..."

az storage account create \
    --name "$STORAGE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --sku Standard_LRS \
    --kind StorageV2 \
    --access-tier Hot \
    --https-only true \
    --min-tls-version TLS1_2 \
    --allow-blob-public-access false \
    --tags Environment=Demo Application=StorageDemo \
    --output table

log "Storage account created successfully!"

# Get storage account details
log "\nStorage account details:"
az storage account show \
    --name "$STORAGE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --query "{Name:name, Location:location, SKU:sku.name, Kind:kind, AccessTier:accessTier}" \
    --output table
```

}

get_storage_keys() {
section “Retrieving Storage Account Keys”

```
log "Getting storage account keys..."

# Get keys
az storage account keys list \
    --account-name "$STORAGE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --output table

# Store first key in variable for later use
STORAGE_KEY=$(az storage account keys list \
    --account-name "$STORAGE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --query "[0].value" \
    --output tsv)

log "Storage keys retrieved successfully!"

# Get connection string
log "\nGetting connection string..."
CONNECTION_STRING=$(az storage account show-connection-string \
    --name "$STORAGE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --query connectionString \
    --output tsv)

log "Connection string retrieved!"
```

}

# ==============================================================================

# BLOB STORAGE OPERATIONS

# ==============================================================================

create_blob_container() {
section “Creating Blob Container”

```
log "Creating blob container: $CONTAINER_NAME"

az storage container create \
    --name "$CONTAINER_NAME" \
    --account-name "$STORAGE_ACCOUNT" \
    --account-key "$STORAGE_KEY" \
    --public-access off \
    --output table

log "Blob container created successfully!"
```

}

upload_blobs() {
section “Uploading Blobs”

```
# Create sample files
log "Creating sample files..."
mkdir -p /tmp/storage-demo
echo "This is a text file for demo purposes." > /tmp/storage-demo/sample.txt
echo "{\"name\": \"demo\", \"type\": \"json\"}" > /tmp/storage-demo/sample.json
echo "<html><body>Demo HTML</body></html>" > /tmp/storage-demo/sample.html

log "Uploading files to blob storage..."

# Upload text file
log "Uploading sample.txt..."
az storage blob upload \
    --account-name "$STORAGE_ACCOUNT" \
    --account-key "$STORAGE_KEY" \
    --container-name "$CONTAINER_NAME" \
    --name "sample.txt" \
    --file "/tmp/storage-demo/sample.txt" \
    --content-type "text/plain" \
    --output table

# Upload JSON file
log "Uploading sample.json..."
az storage blob upload \
    --account-name "$STORAGE_ACCOUNT" \
    --account-key "$STORAGE_KEY" \
    --container-name "$CONTAINER_NAME" \
    --name "sample.json" \
    --file "/tmp/storage-demo/sample.json" \
    --content-type "application/json" \
    --metadata purpose=demo category=json \
    --output table

# Upload HTML file
log "Uploading sample.html..."
az storage blob upload \
    --account-name "$STORAGE_ACCOUNT" \
    --account-key "$STORAGE_KEY" \
    --container-name "$CONTAINER_NAME" \
    --name "sample.html" \
    --file "/tmp/storage-demo/sample.html" \
    --content-type "text/html" \
    --output table

log "All files uploaded successfully!"
```

}

list_blobs() {
section “Listing Blobs”

```
log "Listing all blobs in container: $CONTAINER_NAME"

az storage blob list \
    --account-name "$STORAGE_ACCOUNT" \
    --account-key "$STORAGE_KEY" \
    --container-name "$CONTAINER_NAME" \
    --query "[].{Name:name, Size:properties.contentLength, Type:properties.contentType, Modified:properties.lastModified}" \
    --output table
```

}

download_blob() {
section “Downloading Blob”

```
log "Downloading sample.txt from blob storage..."

mkdir -p /tmp/storage-demo/downloads

az storage blob download \
    --account-name "$STORAGE_ACCOUNT" \
    --account-key "$STORAGE_KEY" \
    --container-name "$CONTAINER_NAME" \
    --name "sample.txt" \
    --file "/tmp/storage-demo/downloads/sample.txt" \
    --output table

log "Blob downloaded successfully!"
log "Content of downloaded file:"
cat /tmp/storage-demo/downloads/sample.txt
```

}

generate_sas_token() {
section “Generating SAS Token”

```
log "Generating SAS token for blob access..."

# Generate SAS token valid for 1 hour
EXPIRY=$(date -u -d "1 hour" '+%Y-%m-%dT%H:%MZ' 2>/dev/null || date -u -v+1H '+%Y-%m-%dT%H:%MZ')

SAS_TOKEN=$(az storage blob generate-sas \
    --account-name "$STORAGE_ACCOUNT" \
    --account-key "$STORAGE_KEY" \
    --container-name "$CONTAINER_NAME" \
    --name "sample.txt" \
    --permissions r \
    --expiry "$EXPIRY" \
    --https-only \
    --output tsv)

log "SAS token generated successfully!"
log "Token is valid until: $EXPIRY"

# Construct URL with SAS token
BLOB_URL="https://${STORAGE_ACCOUNT}.blob.core.windows.net/${CONTAINER_NAME}/sample.txt?${SAS_TOKEN}"

log "\nBlob URL with SAS token:"
echo "$BLOB_URL"

log "\nYou can access the blob with this URL (valid for 1 hour)"
log "Try: curl '$BLOB_URL'"
```

}

# ==============================================================================

# FILE SHARE OPERATIONS

# ==============================================================================

create_file_share() {
section “Creating File Share”

```
log "Creating Azure File Share: $FILE_SHARE_NAME"

az storage share create \
    --account-name "$STORAGE_ACCOUNT" \
    --account-key "$STORAGE_KEY" \
    --name "$FILE_SHARE_NAME" \
    --quota 5 \
    --output table

log "File share created successfully!"
```

}

upload_to_file_share() {
section “Uploading to File Share”

```
log "Uploading file to file share..."

echo "This is a file in Azure File Share" > /tmp/storage-demo/fileshare-sample.txt

az storage file upload \
    --account-name "$STORAGE_ACCOUNT" \
    --account-key "$STORAGE_KEY" \
    --share-name "$FILE_SHARE_NAME" \
    --source "/tmp/storage-demo/fileshare-sample.txt" \
    --path "fileshare-sample.txt" \
    --output table

log "File uploaded to file share!"

log "\nListing files in file share:"
az storage file list \
    --account-name "$STORAGE_ACCOUNT" \
    --account-key "$STORAGE_KEY" \
    --share-name "$FILE_SHARE_NAME" \
    --query "[].{Name:name, Size:properties.contentLength}" \
    --output table
```

}

# ==============================================================================

# QUEUE OPERATIONS

# ==============================================================================

create_queue() {
section “Creating Storage Queue”

```
log "Creating queue: $QUEUE_NAME"

az storage queue create \
    --account-name "$STORAGE_ACCOUNT" \
    --account-key "$STORAGE_KEY" \
    --name "$QUEUE_NAME" \
    --output table

log "Queue created successfully!"
```

}

send_queue_messages() {
section “Sending Messages to Queue”

```
log "Sending messages to queue..."

# Send multiple messages
for i in {1..3}; do
    MESSAGE="Demo message $i - $(date)"
    az storage message put \
        --account-name "$STORAGE_ACCOUNT" \
        --account-key "$STORAGE_KEY" \
        --queue-name "$QUEUE_NAME" \
        --content "$MESSAGE" \
        --output table
    log "Message $i sent"
done

log "\nAll messages sent successfully!"
```

}

peek_queue_messages() {
section “Peeking at Queue Messages”

```
log "Peeking at messages in queue (without removing)..."

az storage message peek \
    --account-name "$STORAGE_ACCOUNT" \
    --account-key "$STORAGE_KEY" \
    --queue-name "$QUEUE_NAME" \
    --num-messages 3 \
    --query "[].{Content:content, InsertionTime:insertionTime}" \
    --output table
```

}

# ==============================================================================

# TABLE OPERATIONS

# ==============================================================================

create_table() {
section “Creating Storage Table”

```
log "Creating table: $TABLE_NAME"

az storage table create \
    --account-name "$STORAGE_ACCOUNT" \
    --account-key "$STORAGE_KEY" \
    --name "$TABLE_NAME" \
    --output table

log "Table created successfully!"
```

}

# ==============================================================================

# STORAGE ANALYTICS & METRICS

# ==============================================================================

enable_storage_logging() {
section “Enabling Storage Analytics”

```
log "Enabling blob logging..."

az storage logging update \
    --account-name "$STORAGE_ACCOUNT" \
    --account-key "$STORAGE_KEY" \
    --services b \
    --log rwd \
    --retention 7 \
    --output table

log "Logging enabled for blob service!"

log "\nShowing logging settings:"
az storage logging show \
    --account-name "$STORAGE_ACCOUNT" \
    --account-key "$STORAGE_KEY" \
    --services b \
    --output table
```

}

# ==============================================================================

# STORAGE ACCOUNT PROPERTIES

# ==============================================================================

show_storage_properties() {
section “Storage Account Properties”

```
log "Fetching storage account properties..."

az storage account show \
    --name "$STORAGE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --query "{Name:name, Location:location, SKU:sku.name, Kind:kind, AccessTier:accessTier, CreationTime:creationTime, HTTPSOnly:enableHttpsTrafficOnly, MinTLSVersion:minimumTlsVersion}" \
    --output table

log "\nFetching storage account usage..."
az storage account show-usage \
    --location "$LOCATION" \
    --output table
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
    
    # Clean up local files
    rm -rf /tmp/storage-demo
    log "Local demo files cleaned up"
else
    log "Skipping cleanup. Remember to delete resources manually to avoid charges:"
    warn "az group delete --name $RESOURCE_GROUP --yes"
fi
```

}

# ==============================================================================

# MAIN EXECUTION

# ==============================================================================

main() {
section “Azure Storage Account Demo”
log “This script demonstrates comprehensive Azure Storage operations”
log “Resource Group: $RESOURCE_GROUP”
log “Storage Account: $STORAGE_ACCOUNT”
log “Location: $LOCATION”

```
# Check prerequisites
check_prerequisites

# Resource group
create_resource_group

# Storage account setup
create_storage_account
get_storage_keys

# Blob storage
create_blob_container
upload_blobs
list_blobs
download_blob
generate_sas_token

# File share
create_file_share
upload_to_file_share

# Queue
create_queue
send_queue_messages
peek_queue_messages

# Table
create_table

# Analytics
enable_storage_logging

# Properties
show_storage_properties

# Success message
section "Demo Completed Successfully!"
log "All storage operations completed!"
log "\nCreated resources:"
log "  - Resource Group: $RESOURCE_GROUP"
log "  - Storage Account: $STORAGE_ACCOUNT"
log "  - Blob Container: $CONTAINER_NAME"
log "  - File Share: $FILE_SHARE_NAME"
log "  - Queue: $QUEUE_NAME"
log "  - Table: $TABLE_NAME"

warn "\n⚠️  IMPORTANT: These resources will incur costs!"
warn "Remember to clean up when done."

# Cleanup prompt
echo ""
cleanup
```

}

# Run main function

main “$@”
