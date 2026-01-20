# Kanva - Windows VM Installation Guide

> **Note:** This deployment uses a local SQLite database by default, which is suitable for pilot projects and evaluation. For production use, configure an external database in `pilot.env`.

The first steps of this install procedure require rebooting the VM.

1. Enable Hypervisor
```powershell
bcdedit /set hypervisorlaunchtype auto
Restart-Computer
```

2. Install Hyper-V:
```powershell
Install-WindowsFeature -Name Hyper-V -IncludeManagementTools -Restart
```

3. Install Containers
```powershell
Install-WindowsFeature -Name Containers -Restart
```

4. Allow web traffic
```powershell
New-NetFirewallRule -DisplayName "Allow HTTP" -Direction Inbound -Protocol TCP -LocalPort 80 -Action Allow -Profile Any
```

5. Download and Install Docker
```powershell
# Invoke-WebRequest is super slow to donwload the file
# Invoke-WebRequest -Uri "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe" -OutFile "DockerDesktopInstaller.exe"
# It's better to download the installer through the browser
Start-Process "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"
```

6. Log into the repository. The password will be provided by Human-Driven AI:
```powershell
docker login kanvaimages.azurecr.io -u KanvaPilot
```

7. Create folder for Kanva:
```powershell
cd c:\
mkdir kanva
cd kanva
```
8. Get configuration files.

    1. Either download these individually:
    - [Docker Compose file](https://raw.githubusercontent.com/Human-Driven-AI/kanva-deployment/refs/heads/main/windows-vm/docker-compose.yml)
    - [Enviromental variables](https://github.com/Human-Driven-AI/kanva-deployment/blob/main/windows-vm/pilot.env)
    2. Or clone the repository:
    ```powershell
    git clone git@github.com:Human-Driven-AI/kanva-deployment.git
    ```
    3. Or download the repository as a zip file:
    - https://github.com/Human-Driven-AI/kanva-deployment/archive/refs/heads/main.zip


Whatever method is used, docker-compose.yml and pilot.env should be placed in C:\kanva.

9. Edit pilot.env

Add a string for the security key:

SecurityKey=""

10. Optional: Set number of replicas
    - Through enviromental variables:
    ```powershell
    setx KANVA_DELPHI_REPLICAS 2
    setx KANVA_PYTHONESS_REPLICAS 2
    # Set for current session or start a new console
    $Env:KANVA_DELPHI_REPLICAS = "2"
    $Env:KANVA_PYTHONESS_REPLICAS = "2"
    ```
    - Or edit docker-compose.yml
    ```
    replicas: ${KANVA_DELPHI_REPLICAS:-2}
    replicas: ${KANVA_PYTHONESS_REPLICAS:-2}
    ```


11. Start Kanva
```powershell
docker-compose up -d
```

## Testing the Installation

### Alternative 1
1. Go to http://localhost/ in the browser within the VM.
2. Go to Data -> Load New Data
3. Select "API/URL"
4. Enter Victoria Electricity Demand as name as URL
5. Enter https://kanvadatasets.blob.core.windows.net/datasets/Victoria%20Electricity%20Demand.parquet 
6. Enter "Date" as "Order By"
7. The data should be l

### Alternative 2:
1. Download https://kanvadatasets.blob.core.windows.net/datasets/Victoria%20Electricity%20Demand.parquet 
2. Go to Data -> Load New Data
3. Drop the file you downloaded in "Drop file here to load data"

After this, Kanva should load the data and you should see "2,16 rows, 14 columns". You should be able to open the dataset and explore the data too.

## Stopping Kanva
Stop Kanva
```powershell
cd c:\kanva
docker-compose down
```

## Updating Kanva
Use the [update-kanva.bat](https://raw.githubusercontent.com/Human-Driven-AI/kanva-deployment/refs/heads/main/windows-vm/update-kanva.bat) script (also available within the windows folder in the repo) or run these commands:

```powershell
cd c:\kanva
# Stop the app
docker-compose down
# Pull containers
docker pull kanvaimages.azurecr.io/efbundle:latest
docker pull kanvaimages.azurecr.io/hub:latest
docker pull kanvaimages.azurecr.io/delphi:latest
docker pull kanvaimages.azurecr.io/pythoness:latest
# Start Kanva again
docker-compose up -d
```