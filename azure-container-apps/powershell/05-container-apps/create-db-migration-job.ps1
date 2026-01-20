param (  
    [string]$customConfig
)

. "$PSScriptRoot\..\utils\utils.ps1"
. "$PSScriptRoot\..\config\variables.ps1"
if ($customConfig) {
    . "$PSScriptRoot\..\config\$customConfig"
}

$imageName="kanvaimages.azurecr.io/efbundle:$dbMigrationLatestImage"

Write-Log "Creating DB migration job"

# Create the Container App Job
az containerapp job create `
  --name $dbMigrationJobName `
  --resource-group $resourceGroupName `
  --environment $containerAppEnvName `
  --trigger-type Manual `
  --replica-timeout 1800 `
  --replica-retry-limit 1 `
  --replica-completion-count 1 `
  --parallelism 1 `
  --image $imageName `
  --registry-server $registryServer `
  --registry-username $registryUsername `
  --registry-password $registryPassword `
  --cpu 0.5 `
  --memory 1Gi `
  --env-vars ConnectionStringsDefault="$connectionString"

# Start the job
az containerapp job start --name $dbMigrationJobName --resource-group $resourceGroupName

# Optional: Wait for the job to complete and check its status
az containerapp job execution list `
  --name $dbMigrationJobName `
  --resource-group $resourceGroupName `
  --output table

Write-Log  "Job created and started. Check the execution list above for status." -ForegroundColor DarkGreen -BackgroundColor White
Write-Log "Done"