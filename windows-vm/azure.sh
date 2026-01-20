
az vm update  --resource-group equinor-pilot_group  --name equinor-pilot-win --set hardwareProfile.additionalProperties.nestedVirtualization=true


bcdedit /set hypervisorlaunchtype auto
Restart-Computer
Install-WindowsFeature -Name Hyper-V -IncludeManagementTools -Restart
Install-WindowsFeature -Name Containers -Restart

# Allow web traffic
New-NetFirewallRule -DisplayName "Allow HTTP" -Direction Inbound -Protocol TCP -LocalPort 80 -Action Allow -Profile Any

# Download and Install Docker
# Invoke-WebRequest is super slow to donwload the file
#Invoke-WebRequest -Uri "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe" -OutFile "DockerDesktopInstaller.exe"
# Better to open the browser
Start-Process "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"

docker login kanvaimages.azurecr.io -u KanvaPilot

https://github.com/Human-Driven-AI/kanva-pilot/archive/refs/heads/main.zip

docker-compose up -d

cd c:\
mkdir kanva
cd kanva

# Install IIS and configure it as an HTTPS proxy to the app

Install-WindowsFeature -Name Web-Server -IncludeManagementTools
Install-WindowsFeature -Name Web-Server, Web-Http-Redirect, Web-Mgmt-Console -IncludeManagementTools
#Install-WindowsFeature -Name Web-Server, Web-Mgmt-Tools, Web-Http-Redirect, Web-Url-Auth, Web-Filtering -IncludeManagementTools

$cert = New-SelfSignedCertificate -DnsName "kanva-pilot.norwayeast.cloudapp.azure.com" -CertStoreLocation "cert:\LocalMachine\My" -NotAfter (Get-Date).AddYears(1) -KeyExportPolicy Exportable
$cert.Thumbprint
DBFF50AB790914373BF6C69F4DE4E8A732C5905E

$password = Read-Host -Prompt "Enter the password for the certificate" -AsSecureString
Export-PfxCertificate -Cert $cert -FilePath C:\kanva\kanva-pilot.pfx -Password $password
New-Item -Path IIS:\SslBindings\0.0.0.0!443 -Value $certBinding

$binding = New-WebBinding -Name "Default Web Site" -IPAddress "*" -Port 443 -Protocol https
$certBinding = Get-Item "cert:\LocalMachine\My\$certThumbprint"

