param (
    [Parameter(Mandatory=$true)]
    [string]$containerAppName,
    [Parameter(Mandatory=$true)]
    [string]$tag,
    [Parameter(Mandatory=$true)]
    [string]$imageName,
    [string]$customConfig
)

. "$PSScriptRoot\..\utils\utils.ps1"
. "$PSScriptRoot\..\config\variables.ps1"
if ($customConfig) {
    . "$PSScriptRoot\..\config\$customConfig"
}

$imageName = "${registryServer}/${imageName}:${tag}"

Write-Log "Creating new revision for container app $containerAppName with imageName $imageName"

az containerapp update `
    --subscription $subscriptionId `
    --resource-group $resourceGroupName `
    --name $containerAppName `
    --image $imageName `
    --revision-suffix $tag
Write-Log "New revision $revision created for $containerAppName"

# Write-Log "Activating revision $tag"
# az containerapp revision activate --revision "${containerAppName}--${tag}" `
#     --name $containerAppName `
#     --resource-group $resourceGroupName

Write-Log "Done"