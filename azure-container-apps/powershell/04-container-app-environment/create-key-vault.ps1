param(
    [string]$customConfig
)

. "$PSScriptRoot\..\utils\utils.ps1"
. "$PSScriptRoot\..\config\variables.ps1"
if ($customConfig) {
    . "$PSScriptRoot\..\config\$customConfig"
}

if (Test-KeyVaultExists -resourceGroupName $resourceGroupName -keyVaultName $keyVaultName) {
    Write-Log "Key Vault $keyVaultName already exists."
    $keyVaultUrl = "https://$keyVaultName.vault.azure.net/"
} 
else {
    if (Test-KeyVaultSoftDeleted -keyVaultName $keyVaultName -location $location) {
        Write-Log "Key Vault $keyVaultName is soft-deleted, purging. This may take a few minutes."
        az keyvault purge --location $location --name $keyVaultName
    }
    
    Write-Log "Creating Key Vault $keyVaultName"
    $publicNetworkAccess = "Disabled"
    if ($createPublicKeyVault) {
        $publicNetworkAccess = "Enabled"
    }
    # Create the Key Vault
    $keyVaultUrl = $(az keyvault create `
            --name $keyVaultName `
            --resource-group $resourceGroupName `
            --location $location `
            --sku Standard `
            --enable-rbac-authorization false `
            --public-network-access $publicNetworkAccess `
            --enabled-for-deployment false `
            --enabled-for-disk-encryption false `
            --enabled-for-template-deployment false `
            --retention-days 90 `
            --query "properties.vaultUri" `
            --output tsv)
}

$configFileToUse = if ($customConfig) { $customConfig } else { "variables.ps1" }
$configPath = "$PSScriptRoot\..\config\$configFileToUse"
Update-ConfigVariable -ConfigFile $configPath -VariableName "keyVaultUrl" -VariableValue $keyVaultUrl

Write-Log "Done"