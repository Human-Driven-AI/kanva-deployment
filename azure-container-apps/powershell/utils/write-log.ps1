function Write-Log {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [System.ConsoleColor]$ForegroundColor = [System.ConsoleColor]::White,
        
        [Parameter(Mandatory=$false)]
        [System.ConsoleColor]$BackgroundColor = [System.ConsoleColor]::Black
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $Message"
    
    # Write to console
    Write-Host $logMessage -ForegroundColor $ForegroundColor -BackgroundColor $BackgroundColor
    
    # Write to log file
    $logFile = Join-Path $PSScriptRoot "setup-kanva.log"
    Add-Content -Path $logFile -Value $logMessage
}