[CmdletBinding()]
param
(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]$StatePath,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]$SettingsFilePath
)


Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

Import-Module ".\StateHelpers.psm1" -Force

try {
    Push-Location $PSScriptRoot
    $usmtPath = "C:\\Program Files (x86)\\Windows Kits\\10\\Assessment and Deployment Kit\\User State Migration Tool\\amd64"
    $cmdLine = "loadstate.exe"
    if (Test-Path -Path (Join-Path -Path $usmtPath -ChildPath $cmdLine)) {
        Write-Host "  USMT installed..."
    }
    else {
        Write-Host "  Installing USMT..."
        Install-USMT
    }
    
    # set the path once we know the toolkit is installed...
    Set-Location $usmtPath

    $logFilename = "load.log"
    $logFilePath = Join-Path -path $StatePath -ChildPath $logFilename
    $args = @($StatePath, "/i:$SettingsFilePath", "/v:5", "/l:$logFilePath", "/c")
    Write-Host "  Calling scanstate...  Args:  $args"
    $exitCode = Start-Process -FilePath $cmdLine -ArgumentList $args -PassThru -Wait
    Write-Host "  ... completed (exit code:  {0})", $exitCode


<#     $layoutPath = "userStartLayout.xml"
    $filepath = Join-Path -path $StatePath -ChildPath $layoutPath
    if (test-path $filepath) {
        Write-Host "  Calling Import-StartLayout (filepath:  $filepath)"
        Import-StartLayout -Path $filepath
        Write-Host "  ... completed."
    }
    else {
        Write-host "  export file DNE:  $filepath"
    }
 #>

}
finally {
    Pop-Location
}
