# Azure Container Apps Deployment (Bash)

Bash scripts to deploy Kanva to Azure Container Apps.

## Requirements

- Bash
- Azure CLI

## Instructions

1. Copy `config/variables-sample.sh` and save it as `config/variables.sh`
2. Edit the subscription ID and other variables as required
3. Run `./setup-kanva.sh`

The setup script presents an interactive menu allowing you to run each step independently:

1. Create Resource Group
2. Create Storage Account
3. Create Projects Database
4. Create Container App Environment
5. Create Container Apps
6. Create App Registration (For Authentication)

Plus maintenance options (start/stop/update apps) and utilities.

## Custom Configurations

Create custom config files as `config/variables-IDENTIFIER.sh` to manage multiple deployments. They will be listed by the setup script under "Load Config".
