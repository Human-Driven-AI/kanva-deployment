. "$PSScriptRoot\utils\utils.ps1"
. "$PSScriptRoot\config\variables.ps1"

$script:customConfig = $null
$script:subscriptionId = $subscriptionId

function Import-CustomConfig {
    $configFiles = Get-ChildItem -Path "$PSScriptRoot\config" -Filter "variables-*.ps1"
    
    Write-Host "Available configurations:"
    Write-Host "0. Base (default)"
    for ($i = 0; $i -lt $configFiles.Count; $i++) {
        $configName = $configFiles[$i].BaseName -replace '^variables-', ''
        $configName = (Get-Culture).TextInfo.ToTitleCase($configName.ToLower()) -replace '-', ' '
        Write-Host "$($i + 1). $configName"
    }
    Write-Host "C. Cancel"

    while ($true) {
        $selection = Read-Host "Enter the number of the configuration to load, '0' for Base config, or 'C' to cancel"
        
        if ($selection -eq 'C' -or $selection -eq 'c') {
            Write-Host "Operation cancelled. No changes made to configuration."
            return @{
                CustomConfig = $script:customConfig
                SubscriptionId = $script:subscriptionId
            }
        }

        if ($selection -eq '0') {
            . "$PSScriptRoot\config\variables.ps1"
            Write-Host "Loaded base configuration."
            return @{
                CustomConfig = $null
                SubscriptionId = $subscriptionId
            }
        }

        $index = [int]$selection - 1
        if ($index -ge 0 -and $index -lt $configFiles.Count) {
            $selectedConfig = $configFiles[$index].Name
            . "$PSScriptRoot\config\variables.ps1"
            . "$PSScriptRoot\config\$selectedConfig"
            Write-Host "Loaded custom configuration: $selectedConfig"
            return @{
                CustomConfig = $selectedConfig
                SubscriptionId = $subscriptionId  # Assuming $subscriptionId is set in the custom config
            }
        }
        
        Write-Host "Invalid selection. Please try again."
    }
}

# Function to print current configuration
function Show-CurrentConfig {
    . "$PSScriptRoot\config\variables.ps1"
    if ($customConfig) {
        . "$PSScriptRoot\config\$customConfig"
    }
    Write-Host "Current configuration:"
    Write-Host "Subscription ID: $subscriptionId"
    Write-Host "Resource Group: $resourceGroupName"
    Write-Host "Storage Account: $storageAccountName"
    Write-Host "Location: $location"
    Write-Host "Projects Database: $projectsDatabaseName"
}

# Main menu options
$menuOptions = @(
    @{Name="Create Resource Group"; Script="01-resource-group\create.ps1"; Used=$false},
    @{Name="Create Storage Account"; Script="02-storage-account\create.ps1"; Used=$false},
    @{Name="Create Projects Database"; Script="03-projects-database\create.ps1"; Used=$false},
    @{Name="Create Container App Environment"; Script="04-container-app-environment\create.ps1"; Used=$false},
    @{Name="Create Container Apps"; Script="05-container-apps\create.ps1"; Used=$false},
    @{Name="Create App Registration (For Authentication)"; Script="06-app-registration\create.ps1"; Used=$false},
    @{Name="Maintenance"; Script=$null; Used=$false},
    @{Name="Utils"; Script=$null; Used=$false},
    @{Name="Print Current Config"; Script=$null; Used=$false},
    @{Name="Load Config"; Script=$null; Used=$false}
)

# Function to display the menu
function Show-Menu {
    $currentConfig = if ($script:customConfig) { 
        ($script:customConfig -replace '^variables-', '' -replace '\.ps1$', '') -replace '-', ' '
    } else { 
        "Base" 
    }
    
    $menuWidth = 60
    $configDisplay = "Config: $currentConfig ($script:subscriptionId)".PadLeft($menuWidth)
    
    Clear-Host
    Write-Host $configDisplay
    Write-Host (" " * $menuWidth) -BackgroundColor White
    Write-Host " Kanva Setup".PadRight($menuWidth) -ForegroundColor DarkGreen -BackgroundColor White
    Write-Host (" " * $menuWidth) -BackgroundColor White
    Write-Host ("")
    
    for ($i = 0; $i -lt 6; $i++) {
        $checkMark = if ($menuOptions[$i].Used) { "[✅] " } else { "[ ]" }
        Write-Host ("{0,2}. {1} {2}" -f ($i + 1), $menuOptions[$i].Name, $checkMark)
    }
    for ($i = 6; $i -lt $menuOptions.Count; $i++) {
        Write-Host ("{0,2}. {1}" -f ($i + 1), $menuOptions[$i].Name)
    }
    Write-Host " E. Exit"
    Write-Host ("")
    Write-Host ("=" * $menuWidth)
}

# Function to run a script and mark it as used
function Invoke-MenuOption {
    param (
        [int]$Index
    )
    
    if ($Index -ge 0 -and $Index -lt $menuOptions.Count) {
        $option = $menuOptions[$Index]
        if ($option.Script) {            
            $activeSubscription = Get-ActiveAzureSubscription
            if ($activeSubscription.id -ne $script:subscriptionId) {
                Write-Log "Switching to subscription $subscriptionId"                
                az account set --subscription $subscriptionId
            }
            
            & "$PSScriptRoot\$($option.Script)" $script:customConfig
            $option.Used = $true
        }
        elseif ($option.Name -eq "Maintenance") {
            Show-MaintenanceMenu
        }
        elseif ($option.Name -eq "Utils") {
            Show-UtilsMenu
        }
        elseif ($option.Name -eq "Print Current Config") {
            Show-CurrentConfig
        }
        elseif ($option.Name -eq "Load Config") {
            $result = Import-CustomConfig
            $script:customConfig = $result.CustomConfig
            $script:subscriptionId = $result.SubscriptionId
        }
        elseif ($option.Name -eq "Exit") {
            return $false
        }
    }
    else {
        Write-Host "Invalid selection"
    }
    return $true
}

function Show-MaintenanceMenu {
    Write-Host "Maintenance submenu:"
    Write-Host "1. Start Apps"
    Write-Host "2. Stop Apps"
    Write-Host "3. Update Apps To Latest Revision"
    Write-Host "4. Back to Main Menu"
    
    az account set --subscription $subscriptionId
    $subSelection = Read-Host "Enter your choice"
    switch ($subSelection) {
        "1" { & "$PSScriptRoot\07-maintenance\start.ps1" $script:customConfig }
        "2" { & "$PSScriptRoot\07-maintenance\stop.ps1" $script:customConfig }
        "3" { & "$PSScriptRoot\07-maintenance\update.ps1" $script:customConfig }
        "4" { return }
        default { Write-Host "Invalid selection" }
    }
    $menuOptions[6].Used = $true
}

function Show-UtilsMenu {
    Write-Host "Utils submenu:"
    Write-Host "1. Fetch Last Container Tags"
    Write-Host "2. List Files"
    Write-Host "3. Back to Main Menu"
    
    $subSelection = Read-Host "Enter your choice"
    switch ($subSelection) {
        "1" { & "$PSScriptRoot\utils\fetch-last-container-tags.ps1" $script:customConfig }
        "2" { & "$PSScriptRoot\utils\list_files.ps1" $script:customConfig }
        "3" { return }
        default { Write-Host "Invalid selection" }
    }
    $menuOptions[7].Used = $true
}

# Main loop
$continue = $true
while ($continue) {
    Show-Menu
    $selection = Read-Host "Enter your choice"
    
    if ($selection -eq "e" -or $selection -eq "E") {
        $continue = $false
    }
    else {
        $continue = Invoke-MenuOption ([int]$selection - 1)
    }

    if ($continue) {
        Write-Host "Press Enter to continue..."
        Read-Host | Out-Null
    }
}