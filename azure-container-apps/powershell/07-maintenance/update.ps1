param(
    [string]$customConfig
)

. "$PSScriptRoot\..\utils\utils.ps1"
. "$PSScriptRoot\..\config\variables.ps1"
if ($customConfig) {
    . "$PSScriptRoot\..\config\$customConfig"
}

Write-Host "Updating container apps"
. "$PSScriptRoot\create-revision.ps1" -customConfig $customConfig -containerAppName $hubAppName -imageName "hub" -tag $hubLatestImage
. "$PSScriptRoot\create-revision.ps1" -customConfig $customConfig -containerAppName $delphiAppName -imageName "delphi" -tag $delphiLatestImage
. "$PSScriptRoot\create-revision.ps1" -customConfig $customConfig -containerAppName $pythonessAppName -imageName "pythoness" -tag $pythonessLatestImage
Write-Host "Done"