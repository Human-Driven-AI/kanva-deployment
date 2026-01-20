param(
    [string]$customConfig
)

. "$PSScriptRoot\..\utils\utils.ps1"
. "$PSScriptRoot\..\config\variables.ps1"
if ($customConfig) {
    . "$PSScriptRoot\..\config\$customConfig"
}

Write-Log "Creating resource group $resourceGroupName for subscription $subscriptionId in location $location"
az account set --subscription $subscriptionId
az group create --name $resourceGroupName --location $location
Write-Log "Done"