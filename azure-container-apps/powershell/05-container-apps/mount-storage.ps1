param (
    [string]$containerAppName,    
    [string]$customConfig
)

. "$PSScriptRoot\..\utils\utils.ps1"
. "$PSScriptRoot\..\config\variables.ps1"
if ($customConfig) {
    . "$PSScriptRoot\..\config\$customConfig"
}

if (-not (Get-Module -ListAvailable -Name powershell-yaml)) {
    Install-Module -Name powershell-yaml -Force -Scope CurrentUser
} else {
    Write-Log "PowerShell-yaml module is already installed."
}

Import-Module powershell-yaml

$revisionSuffix = Get-Date -Format "yyyyMMdd-HHmm"

Write-Log "Reading container app configuration"
az containerapp show `
  --name $containerAppName `
  --resource-group $resourceGroupName `
  --output yaml > app.yaml

# Read and parse the YAML content
$yamlContent = Get-Content -Path app.yaml -Raw
$config = ConvertFrom-Yaml $yamlContent

# Modify the configuration
$config.properties.template.volumes = @(
    @{
        mountOptions = "dir_mode=0777,file_mode=0777,cache=none"
        name = $fileShareName
        storageName = $fileShareName
        storageType = "AzureFile"
    }
)

if ($null -eq $config.properties.template.containers[0].volumeMounts) {
    $config.properties.template.containers[0].volumeMounts = @()
}

$config.properties.template.containers[0].volumeMounts += @{
    volumeName = $fileShareName
    mountPath = "/app/data"
}

$config.properties.template.revisionSuffix = $revisionSuffix

# Convert back to YAML
$updatedYaml = ConvertTo-Yaml $config

# Save the updated YAML
$updatedYaml | Set-Content -Path updated_app.yaml

Write-Log "Creating new revision with storage mount"
# Update the container app with the new configuration
az containerapp update `
  --name $containerAppName `
  --resource-group $resourceGroupName `
  --yaml updated_app.yaml `
  --output table

# Remove the temporary files
Remove-Item -Path app.yaml, updated_app.yaml

Write-Log "Done"