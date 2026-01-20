# Azure Container Apps Deployment

Scripts to deploy Kanva to Azure Container Apps using the reference architecture.

## Options

- **[powershell/](powershell/)** - PowerShell scripts (requires PowerShell and Azure CLI)
- **[bash/](bash/)** - Bash scripts (requires Bash and Azure CLI)

## Flexibility

The setup script provides an interactive menu that allows you to run each step independently:

1. Create Resource Group
2. Create Storage Account
3. Create Projects Database
4. Create Container App Environment
5. Create Container Apps
6. Create App Registration (for authentication)

This modular approach lets you:
- Use an existing resource group
- Use an existing database
- Use an existing Key Vault
- Skip steps that don't apply to your setup
- Re-run individual steps if needed

## Azure Resources

- Resource Group (optional - can use existing)
- Storage Account (for data files)
- Azure SQL Database (for project metadata - can use existing)
- Key Vault (for secrets - can use existing)
- Container App Environment with Kanva containers (Hub, Delphi, Pythoness)

## Requirements

- Azure subscription
- Azure CLI installed and logged in
- Container registry credentials from Human-Driven AI
