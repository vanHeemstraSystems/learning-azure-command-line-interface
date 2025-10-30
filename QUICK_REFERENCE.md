# Azure CLI Quick Reference Guide

## Essential Commands

### Authentication

```bash
az login                                    # Login to Azure
az account list --output table             # List all subscriptions
az account show                            # Show current subscription
az account set --subscription "NAME"       # Switch subscription
```

### Resource Groups

```bash
az group create --name RG --location LOC   # Create resource group
az group list --output table               # List all resource groups
az group show --name RG                    # Show RG details
az group delete --name RG --yes            # Delete resource group
```

### Storage Accounts

```bash
az storage account create --name NAME --resource-group RG --location LOC --sku Standard_LRS
az storage account list --output table
az storage account keys list --account-name NAME --resource-group RG
az storage container create --name CONTAINER --account-name NAME
az storage blob upload --account-name NAME --container-name CONTAINER --name BLOB --file FILE
```

### Virtual Machines

```bash
az vm create --resource-group RG --name VM --image UbuntuLTS --size Standard_B1s --admin-username USER --generate-ssh-keys
az vm list --output table
az vm list --show-details --output table   # Include power state
az vm start --name VM --resource-group RG
az vm stop --name VM --resource-group RG   # Stops but keeps billing
az vm deallocate --name VM --resource-group RG  # Stops billing
az vm delete --name VM --resource-group RG --yes
```

### Querying Resources

```bash
az resource list --output table            # All resources
az resource list --resource-type TYPE      # Filter by type
az resource list --location LOC            # Filter by location
az resource list --tag KEY=VALUE           # Filter by tag
```

### Output Formats

```bash
--output json       # Default, structured data
--output table      # Human-readable table
--output tsv        # Tab-separated (parsing)
--output yaml       # YAML format
--output jsonc      # JSON with colors
```

### JMESPath Queries

```bash
--query "[].name"                          # Get all names
--query "[?location=='eastus']"            # Filter by location
--query "[].{Name:name, RG:resourceGroup}" # Custom columns
```

### Common Options

```bash
--help              # Show help for command
--verbose           # Verbose output
--debug             # Debug output
--yes               # Skip confirmation prompts
--no-wait           # Don't wait for long operations
```

## Azure Regions (Common)

- `eastus` - East US
- `eastus2` - East US 2
- `westus` - West US
- `westus2` - West US 2
- `centralus` - Central US
- `westeurope` - West Europe
- `northeurope` - North Europe
- `southeastasia` - Southeast Asia

## VM Sizes (Common)

- `Standard_B1s` - 1 vCPU, 1 GB RAM (cheapest)
- `Standard_B2s` - 2 vCPU, 4 GB RAM
- `Standard_D2s_v3` - 2 vCPU, 8 GB RAM
- `Standard_D4s_v3` - 4 vCPU, 16 GB RAM

## Storage SKUs

- `Standard_LRS` - Locally redundant (cheapest)
- `Standard_GRS` - Geo-redundant
- `Premium_LRS` - Premium, locally redundant

## Best Practices

1. Always tag resources: `--tags Environment=Dev Project=Learning`
1. Use meaningful names with consistent naming conventions
1. Set defaults: `az config set defaults.location=eastus`
1. Delete resources when done to avoid costs
1. Use `--dry-run` when available to test commands
1. Store sensitive data in Azure Key Vault, not in scripts

## Cost Management Tips

- Use B-series VMs for development (burstable, cheaper)
- Deallocate VMs when not in use (`az vm deallocate`)
- Delete entire resource groups to remove all resources
- Use Azure Cost Management to monitor spending
- Set up budget alerts in the Azure Portal

## Troubleshooting

```bash
az version                  # Check CLI version
az find "keyword"           # Search for commands
az interactive              # Interactive mode
az self-test               # Test CLI installation
az upgrade                 # Upgrade Azure CLI
```

## Useful Extensions

```bash
az extension list                           # List installed extensions
az extension add --name EXTENSION_NAME      # Install extension
az extension update --name EXTENSION_NAME   # Update extension
```

Popular extensions:

- `azure-devops` - Azure DevOps
- `aks-preview` - AKS preview features
- `application-insights` - App Insights

## Environment Variables

```bash
export AZURE_DEFAULTS_LOCATION=eastus
export AZURE_DEFAULTS_GROUP=my-rg
```

## Quick Resource Cleanup

```bash
# List all resource groups
az group list --query "[].name" -o tsv

# Delete all resources in a resource group
az group delete --name RG --yes --no-wait

# Delete multiple resource groups at once
az group list --tag Environment=Dev --query "[].name" -o tsv | xargs -I {} az group delete --name {} --yes --no-wait
```

## Common Errors

### “Resource group not found”

- Verify RG name: `az group list --output table`
- Check you’re in correct subscription

### “The subscription is disabled”

- Switch to correct subscription: `az account set --subscription "NAME"`

### “Name not available”

- Storage account names must be globally unique
- Try adding numbers or your initials

### “Insufficient permissions”

- Check your role: `az role assignment list --assignee YOUR_EMAIL`
- Need at least Contributor role

## Learning Resources

- [Official Docs](https://docs.microsoft.com/en-us/cli/azure/)
- [Azure CLI GitHub](https://github.com/Azure/azure-cli)
- [Microsoft Learn](https://docs.microsoft.com/en-us/learn/modules/control-azure-services-with-cli/)
