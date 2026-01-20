. "$PSScriptRoot\test-resource-exists.ps1"
. "$PSScriptRoot\write-config.ps1"
. "$PSScriptRoot\write-log.ps1"


function Get-ActiveAzureSubscription {
    $subscription = az account show --query '{name:name, id:id, tenantId:tenantId}' --output json | ConvertFrom-Json
    
    if ($subscription) {
        return $subscription
    }
    else {
        Write-Error "No active subscription found. Please log in to Azure or set an active subscription."
        return $null
    }
}

function Get-HubUrl {
    param (
        [string]$hubAppName,
        [string]$resourceGroupName
    )
    $hubUrl = az containerapp show `
        --name $hubAppName `
        --resource-group $resourceGroupName `
        --query "properties.configuration.ingress.fqdn" `
        --output tsv
    $hubUrl = "https://$hubUrl/hub-agent"

    return $hubUrl
}

function Test-ContainerAppEnvironmentExists {
    param (
        [string]$containerAppEnvName,
        [string]$resourceGroupName
    )
    
    $exists = az containerapp env show --name $containerAppEnvName --resource-group $resourceGroupName --query "name" --output tsv 2>$null
    
    if ($exists -eq $containerAppEnvName) {
        return $true
    } else {
        return $false
    }
}