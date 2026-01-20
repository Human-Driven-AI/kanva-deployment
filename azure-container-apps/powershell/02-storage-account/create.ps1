param(
    [string]$customConfig
)

. "$PSScriptRoot\..\utils\utils.ps1"
. "$PSScriptRoot\..\config\variables.ps1"
if ($customConfig) {
    . "$PSScriptRoot\..\config\$customConfig"
}

. "$PSScriptRoot\..\utils\write-config.ps1"

Write-Log "Creating storage account $storageAccountName"

az storage account create `
    --name $storageAccountName `
    --resource-group $resourceGroupName `
    --location $location `
    --sku $sku `
    --kind $kind `
    --access-tier $accessTier `
    --enable-hierarchical-namespace true `
    --allow-blob-public-access true `
    --allow-cross-tenant-replication false `
    --min-tls-version TLS1_2 `
    --public-network-access Enabled

# Get the storage account key
$storageAccountKey = (az storage account keys list --resource-group $resourceGroupName --account-name $storageAccountName --query '[0].value' -o tsv)

# Create file share
az storage share create `
    --name $fileShareName `
    --account-name $storageAccountName `
    --account-key $storageAccountKey `
    --quota $fileShareQuota

$configFileToUse = if ($customConfig) { $customConfig } else { "variables.ps1" }
$configPath = "$PSScriptRoot\..\config\$configFileToUse"
Update-ConfigVariable -ConfigFile $configPath -VariableName "storageAccountKey" -VariableValue $storageAccountKey

# Display the storage account key
Write-Log "The new storage account key: $storageAccountKey has been written to $configPath" -ForegroundColor DarkGreen -BackgroundColor White
