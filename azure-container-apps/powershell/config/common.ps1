$location = "norwayeast" # See valid locations in available-locations.txt

# Storage account
$accessTier = "Hot"
$kind = "StorageV2"
$sku = "Standard_LRS"
$fileShareName = $storageAccountName
$fileShareQuota = 5120

# Database
$backupStorageRedundancy = "Local"
$capacity = 2
$computeModel = "Serverless"
$edition = "GeneralPurpose"
$family = "Gen5"
$minCapacity = 0.5

# Container Apps
$containerAppEnvName = "managedEnvironment-KanvaOffer"
$customDomainName = "kanva.human-driven.ai"
$dbMigrationJobName="kanva-db-migration-job"
$logAnalyticsWorkspaceName = "kanva-log-analytics"
$registryName = "kanvaimages"
$registryServer = "kanvaimages.azurecr.io"
$registryUsername = "KanvaPilotCustomer"