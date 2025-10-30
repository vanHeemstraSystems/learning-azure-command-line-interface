# 300 - Learning Our Subject

## Project Overview

This repository showcases hands-on experience with Azure CLI (az) by implementing an Azure Resource Manager tool that demonstrates key cloud infrastructure management capabilities. The project highlights understanding of Azure’s core services, resource management, and infrastructure as code principles.

## What This Project Demonstrates

- **Azure CLI Fundamentals**: Command structure, authentication, and configuration
- **Resource Management**: Creating, querying, updating, and deleting Azure resources
- **Storage Operations**: Blob storage management and operations
- **Compute Resources**: Virtual machine lifecycle management
- **Networking**: Virtual network and security group configuration
- **Cost Management**: Resource monitoring and cost-aware operations
- **Best Practices**: Error handling, idempotent operations, and proper resource cleanup
- **Scripting & Automation**: Programmatic infrastructure management

## Application: Azure Resource Manager CLI Tool

The main application (`azure_resource_manager.py`) is a Python-based CLI tool that wraps Azure CLI commands to provide a user-friendly interface for common Azure operations.

### Features

1. **Resource Group Management**
- Create and delete resource groups
- List all resource groups with detailed information
- Tag-based organization
1. **Storage Account Operations**
- Create storage accounts with various configurations
- Upload and download blobs
- List and manage containers
- Generate SAS tokens
1. **Virtual Machine Management**
- Create VMs with custom configurations
- List VMs with status information
- Start, stop, and delete VMs
- Query VM details
1. **Resource Monitoring**
- List all resources across subscriptions
- Filter resources by type, location, or tags
- Cost estimation and tracking
1. **Interactive Mode**
- Menu-driven interface for easy exploration
- Real-time feedback on operations
- Error handling with helpful messages

## Prerequisites

- **Azure Account**: Active Microsoft Azure subscription
- **Azure CLI**: Version 2.50.0 or higher
- **Python**: Version 3.8 or higher
- **Operating System**: Windows, macOS, or Linux

## Installation

### 1. Install Azure CLI

**Windows:**

```bash
winget install Microsoft.AzureCLI
```

**macOS:**

RECOMMENDED:
``` bash
pip install azure-cli
```

Alternatively

```bash
brew install azure-cli
```

**Linux:**

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### 2. Clone This Repository

```bash
git clone https://github.com/YOUR-USERNAME/learning-azure-command-line-interface.git
cd learning-azure-command-line-interface
```

### 3. Verify Azure CLI Installation

```bash
az --version
```

## Authentication

Before running the application, authenticate with your Azure account:

```bash
az login
```

To verify your current subscription:

```bash
az account show
```

To switch subscriptions if you have multiple:

```bash
az account set --subscription "SUBSCRIPTION_NAME_OR_ID"
```

## Usage

### Create a virtual environment for Python

+++ INSTRUCTIONS GO HERE +++

### Running the Application

**Interactive Mode (Recommended for Learning):**

```bash
python azure_resource_manager.py
```

**Command-Line Mode Examples:**

Create a resource group:

```bash
python azure_resource_manager.py --action create-rg --name my-resource-group --location eastus
```

List all resource groups:

```bash
python azure_resource_manager.py --action list-rg
```

Create a storage account:

```bash
python azure_resource_manager.py --action create-storage --name mystorageacct123 --resource-group my-resource-group
```

List all resources:

```bash
python azure_resource_manager.py --action list-resources
```

### Interactive Menu

The interactive mode provides a guided experience:

```
=== Azure Resource Manager CLI Tool ===

1. Resource Group Operations
2. Storage Account Operations
3. Virtual Machine Operations
4. List All Resources
5. Help & Documentation
6. Exit

Select an option: 
```

## Key Azure CLI Commands Demonstrated

### Authentication & Configuration

```bash
az login                                    # Interactive login
az account list --output table             # List subscriptions
az account set --subscription "SUB_ID"     # Set active subscription
```

### Resource Groups

```bash
az group create --name RG_NAME --location LOCATION
az group list --output table
az group delete --name RG_NAME --yes --no-wait
```

### Storage Accounts

```bash
az storage account create --name ACCOUNT_NAME --resource-group RG_NAME --location LOCATION --sku Standard_LRS
az storage blob upload --account-name ACCOUNT_NAME --container-name CONTAINER --name BLOB_NAME --file FILE_PATH
az storage blob download --account-name ACCOUNT_NAME --container-name CONTAINER --name BLOB_NAME --file FILE_PATH
```

### Virtual Machines

```bash
az vm create --resource-group RG_NAME --name VM_NAME --image UbuntuLTS --admin-username azureuser --generate-ssh-keys
az vm list --output table
az vm start --resource-group RG_NAME --name VM_NAME
az vm stop --resource-group RG_NAME --name VM_NAME
```

### Querying & Filtering

```bash
az resource list --output table
az resource list --resource-type "Microsoft.Compute/virtualMachines"
az resource list --tag Environment=Production
```

## Project Structure

```
Learning-Azure-Command-Line-Interface/
├── README.md                          # This file
├── azure_resource_manager.py          # Main application
├── examples/
│   ├── basic_operations.sh           # Shell script examples
│   ├── storage_demo.sh               # Storage-specific examples
│   └── vm_deployment.sh              # VM deployment examples
├── docs/
│   ├── AZURE_CLI_BASICS.md           # Azure CLI fundamentals
│   ├── BEST_PRACTICES.md             # Best practices guide
│   └── TROUBLESHOOTING.md            # Common issues and solutions
└── .gitignore                         # Git ignore file
```

## Learning Path

This repository follows a structured learning approach:

1. **Foundation** (Week 1)
- Azure CLI installation and configuration
- Understanding Azure hierarchy (subscriptions, resource groups, resources)
- Basic commands and output formatting
1. **Core Services** (Week 2-3)
- Resource group management
- Storage account operations
- Basic compute resources
1. **Advanced Topics** (Week 4)
- Networking and security
- Monitoring and diagnostics
- Cost management
- Automation and scripting
1. **Real-World Projects** (Week 5+)
- Multi-tier application deployment
- CI/CD integration
- Infrastructure as Code

## Best Practices Demonstrated

- **Idempotency**: Operations that can be safely repeated
- **Error Handling**: Graceful failure with informative messages
- **Resource Tagging**: Proper organization and cost tracking
- **Naming Conventions**: Following Azure naming guidelines
- **Security**: Using managed identities and minimal permissions
- **Cost Awareness**: Choosing appropriate SKUs and monitoring usage
- **Cleanup**: Proper resource disposal to avoid unnecessary costs

## Important Notes

⚠️ **Cost Warning**: Running Azure resources incurs costs. Always clean up resources after testing:

```bash
# Delete a resource group and all its resources
az group delete --name YOUR_RESOURCE_GROUP --yes --no-wait
```

💡 **Tip**: Use the `--dry-run` flag (where available) to preview changes before applying them.

## Common Issues & Solutions

### Issue: Authentication Failed

**Solution**: Run `az login` and ensure you’re logged into the correct account.

### Issue: Subscription Not Found

**Solution**: Verify your subscription with `az account list` and set the correct one with `az account set`.

### Issue: Permission Denied

**Solution**: Ensure your account has the necessary permissions (Contributor role or higher).

### Issue: Resource Name Already Exists

**Solution**: Azure resource names must be globally unique. Try a different name or append a unique suffix.

## Resources & Further Learning

- [Official Azure CLI Documentation](https://docs.microsoft.com/en-us/cli/azure/)
- [Azure CLI GitHub Repository](https://github.com/Azure/azure-cli)
- [Azure Quickstart Templates](https://azure.microsoft.com/en-us/resources/templates/)
- [Microsoft Learn - Azure CLI](https://docs.microsoft.com/en-us/learn/modules/control-azure-services-with-cli/)

## Contributing

This is a personal learning project, but suggestions and improvements are welcome! Feel free to:

- Open issues for questions or problems
- Submit pull requests with enhancements
- Share your own learning experiences

## License

MIT License - Feel free to use this code for your own learning purposes.

## Acknowledgments

- Microsoft Azure Documentation Team
- Azure CLI Community Contributors
- Fellow learners and developers

## Author

Created as part of my journey to master Azure cloud infrastructure and CLI automation.

-----

**Happy Learning! ☁️**

