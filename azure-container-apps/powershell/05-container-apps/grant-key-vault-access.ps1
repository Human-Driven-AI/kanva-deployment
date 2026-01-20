param(
    [string]$containerAppName,
    [string]$customConfig,
    [string[]]$secretPermissions = @("get", "list")
)

. "$PSScriptRoot\..\utils\utils.ps1"
. "$PSScriptRoot\..\config\variables.ps1"
if ($customConfig) {
    . "$PSScriptRoot\..\config\$customConfig"
}

$identityName = "${containerAppName}-identity"

# Check if the identity already exists
$existingIdentity = $(az identity show --name $identityName --resource-group $resourceGroupName --query id --output tsv 2>$null)

if ($existingIdentity) {
    Write-Log "Managed identity $identityName already exists."
    $principalId = $(az identity show --name $identityName --resource-group $resourceGroupName --query principalId --output tsv)
    $identityResourceId = $existingIdentity
} else {
    Write-Log "Creating container app managed identity $identityName"
    $principalId = $(az identity create --name $identityName --resource-group $resourceGroupName --query principalId --output tsv)
    $identityResourceId = $(az identity show --name $identityName --resource-group $resourceGroupName --query id --output tsv)
}

$existingPolicy = $(az keyvault show --name $keyVaultName --query "properties.accessPolicies[?objectId=='$principalId']" -o tsv)

if ($existingPolicy) {
    Write-Log "Policy already exists for principalId $principalId. Skipping policy creation."
} else {
    Write-Log "Creating Key Vault policy with permissions: $secretPermissions."
    az keyvault set-policy --name $keyVaultName --object-id $principalId --secret-permissions $secretPermissions
}

Write-Log "Done"

# Get the client ID of the managed identity
$clientId = $(az identity show --name $identityName --resource-group $resourceGroupName --query clientId --output tsv)

# Return both the identity resource ID and the client ID
return @{
    IdentityResourceId = $identityResourceId
    ClientId = $clientId
}