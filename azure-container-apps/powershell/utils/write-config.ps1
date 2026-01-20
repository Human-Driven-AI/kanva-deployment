function Update-ConfigVariable {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ConfigFile,
        
        [Parameter(Mandatory=$true)]
        [string]$VariableName,
        
        [Parameter(Mandatory=$true)]
        [string]$VariableValue
    )

    # Ensure the config file exists
    if (-not (Test-Path $ConfigFile)) {
        throw "Config file not found: $ConfigFile"
    }

    # Read the content of the file
    $content = Get-Content $ConfigFile -Raw

    # Check if the variable already exists in the file
    $pattern = "(?m)^[\s]*\`$$VariableName\s*=.*$"
    if ($content -match $pattern) {
        # Variable exists, update its value
        $updatedLine = "`$$VariableName = `"$VariableValue`""
        $content = $content -replace $pattern, $updatedLine
    } else {
        # Variable doesn't exist, add it at the beginning of the file
        $content = "`$$VariableName = `"$VariableValue`"`r`n$content"
    }

    # Write the updated content back to the file
    $content | Set-Content $ConfigFile -NoNewline
}