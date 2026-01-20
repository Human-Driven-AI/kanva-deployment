param(
    [string]$customConfig
)

. "$PSScriptRoot\..\utils\utils.ps1"
. "$PSScriptRoot\..\config\variables.ps1"
if ($customConfig) {
    . "$PSScriptRoot\..\config\$customConfig"
}

Write-Host "Starting container apps"
$revision = "${hubAppName}--${hubLatestImage}"
az containerapp revision activate --revision $revision --resource-group $resourceGroupName
$revision = "${delphiAppName}--${delphiLatestImage}"
az containerapp revision activate --revision $revision --resource-group $resourceGroupName
$revision = "${pythonessAppName}--${pythonessLatestImage}"
az containerapp revision activate --revision $revision --resource-group $resourceGroupName
Write-Host "Done"