Write-Host "Loading base configuration."

$tenantId = ""
$hdaiTenantId = $tenantId
# This is the only mandatory one
$subscriptionId = ""
$hdaiSubscriptionId = $subscriptionId
# Used to make the identifiers that need it globally unique
$clientSuffix = "tv1"
# This one needs to be unique globally, so add a suffix
# Storage account name must be between 3 and 24 characters in length and use numbers and lower-case letters only
$storageAccountName = "kanvaoffer$clientSuffix"
#                   = "123456789012345678901234"
# This one needs to be unique globally, so add a suffix
$databaseName = "kanva-offer-projects-$clientSuffix"
# Must be unique globally
$keyVaultName = "kanva-key-vault-$clientSuffix"
$createPublicKeyVault = $true
$keyVaultUrl = ""

$resourceGroupName = "Kanva-Offfer"
$storageAccountKey = ""
$adminUser = "sqladmin"
$adminPassword = ""
$connectionString = ""

$registryPassword = ""

$hubAgentUrl = ""
$hubAppName = "kanva-hub"
$delphiAppName = "delphi"
$pythonessAppName = "pythoness"

$dbMigrationLatestImage = "20230823-0417"
$hubLatestImage = "20240919-1144"
$delphiLatestImage = "20240919-0658"
$pythonessLatestImage = "20240919-0655"
$hubUrl = ""

$enableAuthentication = $true
$signInAudience = "AzureADandPersonalMicrosoftAccount"

. "$PSScriptRoot/common.ps1"

