# Kanva Deployment

Deployment scripts and configuration for [Kanva](https://human-driven.ai) - an AI prediction platform that enables domain experts to create state-of-the-art machine learning models based on historical data.

Kanva runs entirely within your infrastructure: no external services are used, no pre-trained models are required, and no data leaves the platform.

## Deployment Options

This repository contains three deployment methods:

### [linux-vm/](linux-vm/)
Docker Compose deployment for Linux VMs (Debian, Ubuntu, and similar distributions).
- Scripted installation via shell scripts
- Suitable for on-premises or cloud VMs, including pilot projects

### [windows-vm/](windows-vm/)
Docker Compose deployment for Windows VMs (Windows Server, Azure VMs).
- Scripted installation with Docker Desktop
- Suitable for on-premises or cloud VMs, including pilot projects

### [azure-container-apps/](azure-container-apps/)
Azure Container Apps deployment using the reference architecture.
- PowerShell scripts (`powershell/`) or Bash scripts (`bash/`)
- Interactive setup with modular steps - use existing resources or create new ones
- Suitable for production Azure deployments

## Requirements

All deployment methods require container registry credentials from Human-Driven AI. Contact [contact@human-driven.ai](mailto:contact@human-driven.ai) to obtain access.

## Support

For issues and questions, please visit: https://github.com/Human-Driven-AI/kanva-deployment/issues
