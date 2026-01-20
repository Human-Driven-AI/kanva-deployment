# Kanva - Linux VM Installation Guide

<img src="../images/kanva-linux-vm.png" alt="Kanva on Linux VM" width="600">

This guide will help you install and run Kanva on Debian, Ubuntu, or other Linux distributions.

> **Note:** This deployment uses a local SQLite database by default, which is suitable for pilot projects and evaluation. For production use, configure an external database in `pilot.env`.

## Prerequisites

- A Linux system (Debian, Ubuntu, or similar)
- Internet connection
- Sudo access

## Installation Steps

### 1. Get Kanva Pilot Setup Scripts

Choose one of the following options:

#### Option A: Using Git (Recommended)

If you want to easily update in the future, use git. First, install git if you don't have it:

```bash
sudo apt-get update && sudo apt-get install -y git
```

Then clone the repository:

```bash
git clone https://github.com/Human-Driven-AI/kanva-deployment.git
cd kanva-deployment/linux-vm
```

#### Option B: Using curl

If you don't want to install git or prefer a quick download:

```bash
curl -L https://github.com/Human-Driven-AI/kanva-deployment/archive/refs/heads/main.tar.gz | tar -xz
cd kanva-deployment-main/linux-vm
```

### 2. Install Docker

Run the installation script to install Docker:

```bash
./01-install-docker.sh
```

This script will:
- Install Docker using the official convenience script
- Start and enable the Docker service
- Add your user to the docker group
- Optionally activate the docker group in your current session

**Important:** When prompted, choose to run `newgrp docker` to activate the docker group, or manually log out and back in.

### 3. Login to Azure Container Registry

After Docker is installed and groups are refreshed, login to the container registry:

```bash
./02-login-registry.sh
```

You will be prompted for a password. Enter the access token provided to you.

### 4. Set Up Data Directory

Configure the data directory and create the `.env` file:

```bash
./03-setup-data-path.sh
```

This script will:
- Read `HostDataPath` from `pilot.env` (defaults to `~/kanva-data`)
- Expand it to an absolute path
- Create the data directory
- Fix ownership if needed
- Generate `.env` file for docker-compose

### 5. Start Kanva

Launch all services:

```bash
./04-start-kanva.sh
```

This will start all containers in detached mode.

### 6. Verify Installation

Check that all services are running:

```bash
docker compose ps
```

Access the web interface at: `http://localhost`

## Updating Kanva

To update to the latest version:

```bash
./update-kanva.sh
```

This script will:
- Stop all running containers
- Pull the latest images
- Restart all services

## Managing Services

### Stop all services
```bash
docker compose down
```

### View logs
```bash
docker compose logs -f
```

### View logs for a specific service
```bash
docker compose logs -f hub
```

### Restart a specific service
```bash
docker compose restart hub
```

## Configuration

### Data Directory

By default, data is stored in `~/kanva-data`. To use a different location, edit `HostDataPath` in `pilot.env` before running `02-setup-data-path.sh`.

### Replicas

To scale the delphi and pythoness agents, set environment variables before starting:

```bash
export KANVA_DELPHI_REPLICAS=2
export KANVA_PYTHONESS_REPLICAS=3
docker compose up -d
```

### Application Settings

Edit `pilot.env` to configure:
- Authentication settings
- CORS origins
- Security keys
- And more

After changing `pilot.env`, restart the services:

```bash
docker compose restart
```

## Troubleshooting

### Permission Issues

If you encounter permission errors (e.g., "Permission denied" when writing to `/app/data`):

```bash
docker compose down
rm -rf ~/kanva-data
./03-setup-data-path.sh
docker compose up -d
```

This stops containers, removes the data directory, recreates it with correct permissions (777), and restarts.

**Note:** The data directory needs 777 permissions because containers run as a different user (UID 5678) than the host user. Removing the directory will delete all data including the database, so only do this if you're starting fresh or have backups.

### Port Conflicts

If port 80 is already in use, modify the port mapping in `docker-compose.yml`:

```yaml
ports:
  - "8080:80"  # Use port 8080 instead
```

### Database Issues

To reset the database, stop all services and remove the database file:

```bash
docker compose down
rm ~/kanva-data/hd.db
docker compose up -d
```

## Support

For issues and questions, please visit: https://github.com/Human-Driven-AI/kanva-deployment/issues