param(
    [string]$customConfig
)

. "$PSScriptRoot\..\utils\utils.ps1"
. "$PSScriptRoot\..\config\variables.ps1"
if ($customConfig) {
    . "$PSScriptRoot\..\config\$customConfig"
}

Write-Log "Creating database server $databaseName"
az sql server create `
    --name $databaseName `
    --resource-group $resourceGroupName `
    --location $location `
    --admin-user $adminUser `
    --admin-password $adminPassword

Write-Log "Creating database $databaseName"
az sql db create `
    --resource-group $resourceGroupName `
    --server $databaseName `
    --name $databaseName `
    --edition GeneralPurpose `
    --family Gen5 `
    --capacity $capacity `
    --zone-redundant false `
    --collation "SQL_Latin1_General_CP1_CI_AS" `
    --max-size 2GB `
    --read-replicas 0 `
    --auto-pause-delay -1 `
    --min-capacity 0.5 `
    --backup-storage-redundancy Local `
    --compute-model $computeModel

Write-Log "Creating firewall rule to allow all Azure services"
az sql server firewall-rule create `
    --resource-group $resourceGroupName `
    --server $databaseName `
    --name "AllowAllAzureServices" `
    --start-ip-address 0.0.0.0 `
    --end-ip-address 0.0.0.0

$connectionString = az sql db show-connection-string `
    --server $databaseName `
    --name $databaseName `
    --client ado.net `
    --output tsv

$connectionString = $connectionString -replace '<username>', $adminUser
$connectionString = $connectionString -replace '<password>', $adminPassword
Write-Host $connectionString 
$configFileToUse = if ($customConfig) { $customConfig } else { "variables.ps1" }
$configPath = "$PSScriptRoot\..\config\$configFileToUse"
Update-ConfigVariable -ConfigFile $configPath -VariableName "connectionString" -VariableValue $connectionString
Write-Log "The new connection string: $connectionString has been written to $configPath" -ForegroundColor DarkGreen -BackgroundColor White
Write-Log "Done"
