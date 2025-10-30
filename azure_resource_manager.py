#!/usr/bin/env python3
“””
Azure Resource Manager CLI Tool

A comprehensive demonstration of Azure CLI capabilities through a Python-based
resource management tool. This application showcases proficiency with Azure CLI
by implementing common cloud infrastructure operations.

Author: Learning Azure CLI Project
License: MIT
“””

import subprocess
import json
import sys
import argparse
from typing import Dict, List, Optional, Any
from datetime import datetime

class AzureCLIManager:
“””
Wrapper class for Azure CLI operations.

```
This class demonstrates how to interact with Azure CLI programmatically,
handle errors, parse JSON responses, and implement common patterns.
"""

def __init__(self):
    """Initialize the Azure CLI Manager and verify Azure CLI is installed."""
    self.verify_azure_cli()
    self.current_subscription = self.get_current_subscription()

def verify_azure_cli(self) -> bool:
    """
    Verify that Azure CLI is installed and accessible.
    
    Returns:
        bool: True if Azure CLI is available, exits otherwise.
    """
    try:
        result = subprocess.run(
            ["az", "--version"],
            capture_output=True,
            text=True,
            check=True
        )
        return True
    except subprocess.CalledProcessError:
        print("❌ Error: Azure CLI is not installed or not in PATH.")
        print("Please install Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli")
        sys.exit(1)
    except FileNotFoundError:
        print("❌ Error: Azure CLI command 'az' not found.")
        print("Please ensure Azure CLI is installed and in your PATH.")
        sys.exit(1)

def run_az_command(self, command: List[str], capture_output: bool = True) -> Optional[Any]:
    """
    Execute an Azure CLI command and return the result.
    
    Args:
        command: List of command parts (e.g., ["az", "group", "list"])
        capture_output: Whether to capture and return output
        
    Returns:
        Parsed JSON output if successful, None otherwise
    """
    try:
        if capture_output:
            command.extend(["--output", "json"])
        
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            check=True
        )
        
        if capture_output and result.stdout:
            try:
                return json.loads(result.stdout)
            except json.JSONDecodeError:
                return result.stdout
        
        return result.stdout if result.stdout else True
        
    except subprocess.CalledProcessError as e:
        print(f"❌ Error executing command: {' '.join(command)}")
        if e.stderr:
            print(f"Details: {e.stderr}")
        return None
    except Exception as e:
        print(f"❌ Unexpected error: {str(e)}")
        return None

def get_current_subscription(self) -> Optional[Dict]:
    """
    Get the currently active Azure subscription.
    
    Returns:
        Dictionary with subscription details or None
    """
    result = self.run_az_command(["az", "account", "show"])
    return result

# ==================== RESOURCE GROUP OPERATIONS ====================

def create_resource_group(self, name: str, location: str, tags: Optional[Dict[str, str]] = None) -> bool:
    """
    Create a new resource group.
    
    Args:
        name: Resource group name
        location: Azure region (e.g., 'eastus', 'westeurope')
        tags: Optional dictionary of tags
        
    Returns:
        bool: True if successful
    """
    print(f"📦 Creating resource group '{name}' in {location}...")
    
    command = ["az", "group", "create", "--name", name, "--location", location]
    
    if tags:
        tag_string = " ".join([f"{k}={v}" for k, v in tags.items()])
        command.extend(["--tags", tag_string])
    
    result = self.run_az_command(command)
    
    if result:
        print(f"✅ Resource group '{name}' created successfully!")
        return True
    return False

def list_resource_groups(self) -> List[Dict]:
    """
    List all resource groups in the current subscription.
    
    Returns:
        List of resource group dictionaries
    """
    print("📋 Fetching resource groups...\n")
    
    result = self.run_az_command(["az", "group", "list"])
    
    if result:
        print(f"{'Name':<30} {'Location':<15} {'Status':<15}")
        print("-" * 60)
        for rg in result:
            name = rg.get('name', 'N/A')
            location = rg.get('location', 'N/A')
            state = rg.get('properties', {}).get('provisioningState', 'N/A')
            print(f"{name:<30} {location:<15} {state:<15}")
        print(f"\n📊 Total resource groups: {len(result)}")
        return result
    return []

def delete_resource_group(self, name: str, no_wait: bool = False) -> bool:
    """
    Delete a resource group and all its resources.
    
    Args:
        name: Resource group name
        no_wait: If True, don't wait for deletion to complete
        
    Returns:
        bool: True if deletion initiated successfully
    """
    print(f"🗑️  Deleting resource group '{name}'...")
    print("⚠️  This will delete ALL resources in the resource group!")
    
    command = ["az", "group", "delete", "--name", name, "--yes"]
    if no_wait:
        command.append("--no-wait")
    
    result = self.run_az_command(command, capture_output=False)
    
    if result:
        if no_wait:
            print(f"✅ Deletion of '{name}' initiated (running in background)")
        else:
            print(f"✅ Resource group '{name}' deleted successfully!")
        return True
    return False

# ==================== STORAGE ACCOUNT OPERATIONS ====================

def create_storage_account(self, name: str, resource_group: str, 
                          location: str = "eastus", sku: str = "Standard_LRS") -> bool:
    """
    Create a storage account.
    
    Args:
        name: Storage account name (must be globally unique, 3-24 lowercase alphanumeric)
        resource_group: Resource group name
        location: Azure region
        sku: Storage SKU (Standard_LRS, Standard_GRS, etc.)
        
    Returns:
        bool: True if successful
    """
    print(f"💾 Creating storage account '{name}'...")
    print(f"   Resource Group: {resource_group}")
    print(f"   Location: {location}")
    print(f"   SKU: {sku}")
    
    command = [
        "az", "storage", "account", "create",
        "--name", name,
        "--resource-group", resource_group,
        "--location", location,
        "--sku", sku
    ]
    
    result = self.run_az_command(command)
    
    if result:
        print(f"✅ Storage account '{name}' created successfully!")
        return True
    return False

def list_storage_accounts(self, resource_group: Optional[str] = None) -> List[Dict]:
    """
    List storage accounts, optionally filtered by resource group.
    
    Args:
        resource_group: Optional resource group to filter by
        
    Returns:
        List of storage account dictionaries
    """
    print("💾 Fetching storage accounts...\n")
    
    command = ["az", "storage", "account", "list"]
    if resource_group:
        command.extend(["--resource-group", resource_group])
    
    result = self.run_az_command(command)
    
    if result:
        print(f"{'Name':<25} {'Resource Group':<30} {'Location':<15} {'SKU':<20}")
        print("-" * 90)
        for sa in result:
            name = sa.get('name', 'N/A')
            rg = sa.get('resourceGroup', 'N/A')
            location = sa.get('location', 'N/A')
            sku = sa.get('sku', {}).get('name', 'N/A')
            print(f"{name:<25} {rg:<30} {location:<15} {sku:<20}")
        print(f"\n📊 Total storage accounts: {len(result)}")
        return result
    return []

def create_blob_container(self, account_name: str, container_name: str) -> bool:
    """
    Create a blob container in a storage account.
    
    Args:
        account_name: Storage account name
        container_name: Container name to create
        
    Returns:
        bool: True if successful
    """
    print(f"📦 Creating container '{container_name}' in account '{account_name}'...")
    
    command = [
        "az", "storage", "container", "create",
        "--name", container_name,
        "--account-name", account_name
    ]
    
    result = self.run_az_command(command)
    
    if result:
        print(f"✅ Container '{container_name}' created successfully!")
        return True
    return False

# ==================== VIRTUAL MACHINE OPERATIONS ====================

def create_vm(self, name: str, resource_group: str, 
              image: str = "UbuntuLTS", size: str = "Standard_B1s",
              admin_username: str = "azureuser") -> bool:
    """
    Create a virtual machine.
    
    Args:
        name: VM name
        resource_group: Resource group name
        image: OS image (e.g., 'UbuntuLTS', 'Win2019Datacenter')
        size: VM size (e.g., 'Standard_B1s', 'Standard_D2s_v3')
        admin_username: Administrator username
        
    Returns:
        bool: True if successful
    """
    print(f"🖥️  Creating virtual machine '{name}'...")
    print(f"   Resource Group: {resource_group}")
    print(f"   Image: {image}")
    print(f"   Size: {size}")
    print("   (This may take several minutes...)")
    
    command = [
        "az", "vm", "create",
        "--resource-group", resource_group,
        "--name", name,
        "--image", image,
        "--size", size,
        "--admin-username", admin_username,
        "--generate-ssh-keys"
    ]
    
    result = self.run_az_command(command)
    
    if result:
        print(f"✅ Virtual machine '{name}' created successfully!")
        if isinstance(result, dict):
            public_ip = result.get('publicIpAddress', 'N/A')
            print(f"   Public IP: {public_ip}")
        return True
    return False

def list_vms(self, resource_group: Optional[str] = None) -> List[Dict]:
    """
    List virtual machines, optionally filtered by resource group.
    
    Args:
        resource_group: Optional resource group to filter by
        
    Returns:
        List of VM dictionaries
    """
    print("🖥️  Fetching virtual machines...\n")
    
    command = ["az", "vm", "list"]
    if resource_group:
        command.extend(["--resource-group", resource_group])
    command.append("--show-details")
    
    result = self.run_az_command(command)
    
    if result:
        print(f"{'Name':<25} {'Resource Group':<30} {'Location':<15} {'Power State':<20}")
        print("-" * 90)
        for vm in result:
            name = vm.get('name', 'N/A')
            rg = vm.get('resourceGroup', 'N/A')
            location = vm.get('location', 'N/A')
            power_state = vm.get('powerState', 'N/A')
            print(f"{name:<25} {rg:<30} {location:<15} {power_state:<20}")
        print(f"\n📊 Total VMs: {len(result)}")
        return result
    return []

def start_vm(self, name: str, resource_group: str) -> bool:
    """Start a virtual machine."""
    print(f"▶️  Starting VM '{name}'...")
    command = ["az", "vm", "start", "--name", name, "--resource-group", resource_group]
    result = self.run_az_command(command, capture_output=False)
    if result:
        print(f"✅ VM '{name}' started successfully!")
        return True
    return False

def stop_vm(self, name: str, resource_group: str) -> bool:
    """Stop (deallocate) a virtual machine."""
    print(f"⏹️  Stopping VM '{name}'...")
    command = ["az", "vm", "deallocate", "--name", name, "--resource-group", resource_group]
    result = self.run_az_command(command, capture_output=False)
    if result:
        print(f"✅ VM '{name}' stopped successfully!")
        return True
    return False

# ==================== RESOURCE QUERY OPERATIONS ====================

def list_all_resources(self, resource_type: Optional[str] = None) -> List[Dict]:
    """
    List all resources, optionally filtered by type.
    
    Args:
        resource_type: Optional resource type filter (e.g., 'Microsoft.Compute/virtualMachines')
        
    Returns:
        List of resource dictionaries
    """
    print("🔍 Fetching all resources...\n")
    
    command = ["az", "resource", "list"]
    if resource_type:
        command.extend(["--resource-type", resource_type])
    
    result = self.run_az_command(command)
    
    if result:
        print(f"{'Name':<30} {'Type':<40} {'Location':<15}")
        print("-" * 85)
        for resource in result[:20]:  # Limit display to first 20
            name = resource.get('name', 'N/A')
            rtype = resource.get('type', 'N/A').split('/')[-1]  # Get last part of type
            location = resource.get('location', 'N/A')
            print(f"{name:<30} {rtype:<40} {location:<15}")
        
        total = len(result)
        print(f"\n📊 Total resources: {total}")
        if total > 20:
            print(f"   (Showing first 20 of {total})")
        return result
    return []

def get_resource_by_tag(self, tag_name: str, tag_value: str) -> List[Dict]:
    """Query resources by tag."""
    print(f"🏷️  Fetching resources with tag {tag_name}={tag_value}...\n")
    
    command = ["az", "resource", "list", "--tag", f"{tag_name}={tag_value}"]
    result = self.run_az_command(command)
    
    if result:
        for resource in result:
            print(f"  - {resource.get('name')} ({resource.get('type')})")
        print(f"\n📊 Found {len(result)} resources")
        return result
    return []
```

class AzureCLIApp:
“”“Main application class with CLI and interactive mode.”””

```
def __init__(self):
    self.manager = AzureCLIManager()

def show_banner(self):
    """Display application banner."""
    print("\n" + "="*60)
    print("  Azure Resource Manager CLI Tool")
    print("  Learning Azure CLI through practical examples")
    print("="*60)
    
    if self.manager.current_subscription:
        sub_name = self.manager.current_subscription.get('name', 'Unknown')
        sub_id = self.manager.current_subscription.get('id', 'Unknown')
        print(f"\n📍 Current Subscription: {sub_name}")
        print(f"   ID: {sub_id}")
    print()

def interactive_mode(self):
    """Run the application in interactive mode."""
    self.show_banner()
    
    while True:
        print("\n" + "="*60)
        print("Main Menu")
        print("="*60)
        print("1. Resource Group Operations")
        print("2. Storage Account Operations")
        print("3. Virtual Machine Operations")
        print("4. Query All Resources")
        print("5. Display Current Subscription Info")
        print("6. Exit")
        print()
        
        choice = input("Select an option (1-6): ").strip()
        
        if choice == "1":
            self.resource_group_menu()
        elif choice == "2":
            self.storage_menu()
        elif choice == "3":
            self.vm_menu()
        elif choice == "4":
            self.manager.list_all_resources()
            input("\nPress Enter to continue...")
        elif choice == "5":
            self.show_subscription_info()
        elif choice == "6":
            print("\n👋 Thank you for using Azure Resource Manager CLI Tool!")
            print("   Happy cloud computing!\n")
            break
        else:
            print("❌ Invalid option. Please select 1-6.")

def resource_group_menu(self):
    """Resource group operations submenu."""
    while True:
        print("\n" + "-"*60)
        print("Resource Group Operations")
        print("-"*60)
        print("1. Create Resource Group")
        print("2. List Resource Groups")
        print("3. Delete Resource Group")
        print("4. Back to Main Menu")
        print()
        
        choice = input("Select an option (1-4): ").strip()
        
        if choice == "1":
            name = input("Enter resource group name: ").strip()
            location = input("Enter location (e.g., eastus, westeurope): ").strip()
            self.manager.create_resource_group(name, location)
            input("\nPress Enter to continue...")
        elif choice == "2":
            self.manager.list_resource_groups()
            input("\nPress Enter to continue...")
        elif choice == "3":
            name = input("Enter resource group name to delete: ").strip()
            confirm = input(f"⚠️  Delete '{name}' and ALL its resources? (yes/no): ").strip().lower()
            if confirm == "yes":
                self.manager.delete_resource_group(name, no_wait=True)
            else:
                print("❌ Deletion cancelled.")
            input("\nPress Enter to continue...")
        elif choice == "4":
            break
        else:
            print("❌ Invalid option.")

def storage_menu(self):
    """Storage account operations submenu."""
    while True:
        print("\n" + "-"*60)
        print("Storage Account Operations")
        print("-"*60)
        print("1. Create Storage Account")
        print("2. List Storage Accounts")
        print("3. Create Blob Container")
        print("4. Back to Main Menu")
        print()
        
        choice = input("Select an option (1-4): ").strip()
        
        if choice == "1":
            name = input("Enter storage account name (3-24 lowercase alphanumeric): ").strip()
            rg = input("Enter resource group name: ").strip()
            location = input("Enter location (e.g., eastus) [default: eastus]: ").strip() or "eastus"
            self.manager.create_storage_account(name, rg, location)
            input("\nPress Enter to continue...")
        elif choice == "2":
            self.manager.list_storage_accounts()
            input("\nPress Enter to continue...")
        elif choice == "3":
            account = input("Enter storage account name: ").strip()
            container = input("Enter container name: ").strip()
            self.manager.create_blob_container(account, container)
            input("\nPress Enter to continue...")
        elif choice == "4":
            break
        else:
            print("❌ Invalid option.")

def vm_menu(self):
    """Virtual machine operations submenu."""
    while True:
        print("\n" + "-"*60)
        print("Virtual Machine Operations")
        print("-"*60)
        print("1. Create VM")
        print("2. List VMs")
        print("3. Start VM")
        print("4. Stop VM")
        print("5. Back to Main Menu")
        print()
        
        choice = input("Select an option (1-5): ").strip()
        
        if choice == "1":
            name = input("Enter VM name: ").strip()
            rg = input("Enter resource group name: ").strip()
            print("\n⚠️  Creating a VM will incur costs!")
            confirm = input("Continue? (yes/no): ").strip().lower()
            if confirm == "yes":
                self.manager.create_vm(name, rg)
            else:
                print("❌ VM creation cancelled.")
            input("\nPress Enter to continue...")
        elif choice == "2":
            self.manager.list_vms()
            input("\nPress Enter to continue...")
        elif choice == "3":
            name = input("Enter VM name: ").strip()
            rg = input("Enter resource group name: ").strip()
            self.manager.start_vm(name, rg)
            input("\nPress Enter to continue...")
        elif choice == "4":
            name = input("Enter VM name: ").strip()
            rg = input("Enter resource group name: ").strip()
            self.manager.stop_vm(name, rg)
            input("\nPress Enter to continue...")
        elif choice == "5":
            break
        else:
            print("❌ Invalid option.")

def show_subscription_info(self):
    """Display detailed subscription information."""
    if self.manager.current_subscription:
        sub = self.manager.current_subscription
        print("\n" + "="*60)
        print("Current Subscription Details")
        print("="*60)
        print(f"Name: {sub.get('name', 'N/A')}")
        print(f"ID: {sub.get('id', 'N/A')}")
        print(f"State: {sub.get('state', 'N/A')}")
        print(f"Tenant ID: {sub.get('tenantId', 'N/A')}")
        print(f"Is Default: {sub.get('isDefault', 'N/A')}")
    else:
        print("\n❌ Could not retrieve subscription information.")
    input("\nPress Enter to continue...")
```

def main():
“”“Main entry point for the application.”””
parser = argparse.ArgumentParser(
description=“Azure Resource Manager CLI Tool - Learn Azure CLI through practical examples”,
formatter_class=argparse.RawDescriptionHelpFormatter,
epilog=”””
Examples:
python azure_resource_manager.py
python azure_resource_manager.py –action list-rg
python azure_resource_manager.py –action create-rg –name my-rg –location eastus
python azure_resource_manager.py –action list-resources
“””
)

```
parser.add_argument(
    "--action",
    choices=["create-rg", "list-rg", "delete-rg", "create-storage", 
            "list-storage", "create-vm", "list-vm", "list-resources"],
    help="Action to perform (if not specified, runs in interactive mode)"
)
parser.add_argument("--name", help="Resource name")
parser.add_argument("--resource-group", help="Resource group name")
parser.add_argument("--location", default="eastus", help="Azure region")

args = parser.parse_args()

app = AzureCLIApp()

# If no action specified, run interactive mode
if not args.action:
    app.interactive_mode()
    return

# Command-line mode
app.show_banner()

if args.action == "list-rg":
    app.manager.list_resource_groups()
elif args.action == "create-rg":
    if not args.name:
        print("❌ Error: --name required for create-rg action")
        sys.exit(1)
    app.manager.create_resource_group(args.name, args.location)
elif args.action == "delete-rg":
    if not args.name:
        print("❌ Error: --name required for delete-rg action")
        sys.exit(1)
    app.manager.delete_resource_group(args.name, no_wait=True)
elif args.action == "list-storage":
    app.manager.list_storage_accounts(args.resource_group)
elif args.action == "create-storage":
    if not args.name or not args.resource_group:
        print("❌ Error: --name and --resource-group required for create-storage action")
        sys.exit(1)
    app.manager.create_storage_account(args.name, args.resource_group, args.location)
elif args.action == "list-vm":
    app.manager.list_vms(args.resource_group)
elif args.action == "create-vm":
    if not args.name or not args.resource_group:
        print("❌ Error: --name and --resource-group required for create-vm action")
        sys.exit(1)
    app.manager.create_vm(args.name, args.resource_group)
elif args.action == "list-resources":
    app.manager.list_all_resources()
```

if **name** == “**main**”:
main()
