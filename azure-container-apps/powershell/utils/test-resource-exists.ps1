function Test-AzureResourceExists {
    param (
        [Parameter(Mandatory=$true)]
        [string]$resourceGroupName,

        [Parameter(Mandatory=$true)]
        [string]$ResourceName,

        [Parameter(Mandatory=$true)]
        [string]$AzCommand
    )

    $result = Invoke-Expression "$AzCommand --name $ResourceName --resource-group $resourceGroupName --query 'name' --output tsv 2>null"
    
    return ($LASTEXITCODE -eq 0 -and $result -eq $ResourceName)
}

function Test-ContainerAppExists {
    param (
        [Parameter(Mandatory=$true)]
        [string]$resourceGroupName,

        [Parameter(Mandatory=$true)]
        [string]$containerAppName
    )

    return Test-AzureResourceExists -ResourceGroupName $resourceGroupName -ResourceName $containerAppName -AzCommand "az containerapp show"
}

function Test-ContainerAppJobExists {
    param (
        [Parameter(Mandatory=$true)]
        [string]$resourceGroupName,

        [Parameter(Mandatory=$true)]
        [string]$jobName
    )

    return Test-AzureResourceExists -ResourceGroupName $resourceGroupName -ResourceName $jobName -AzCommand "az containerapp job show"
}

function Test-LogAnalyticsWorkspaceExists {
    param (
        [Parameter(Mandatory=$true)]
        [string]$resourceGroupName,

        [Parameter(Mandatory=$true)]
        [string]$workspaceName
    )

    return Test-AzureResourceExists -ResourceGroupName $resourceGroupName -ResourceName $workspaceName -AzCommand "az monitor log-analytics workspace show"
}

function Test-KeyVaultExists {
    param (
        [Parameter(Mandatory=$true)]
        [string]$resourceGroupName,

        [Parameter(Mandatory=$true)]
        [string]$keyVaultName
    )

    return Test-AzureResourceExists -ResourceGroupName $resourceGroupName -ResourceName $keyVaultName -AzCommand "az keyvault show"
}

function Test-KeyVaultSoftDeleted {
    param (
        [Parameter(Mandatory=$true)]
        [string]$keyVaultName,

        [Parameter(Mandatory=$true)]
        [string]$location
    )

    $result = az keyvault list-deleted --query "[?name=='$keyVaultName' && properties.location=='$location'].name" --output tsv 2>$null
    
    return ($LASTEXITCODE -eq 0 -and $result -eq $keyVaultName)
}
