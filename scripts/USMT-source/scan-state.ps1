[CmdletBinding()]
param
(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]$OutPath,

    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [String]$SettingsFilePath
)


Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

try {
    
    Import-Module ".\StateHelpers.psm1" -Force

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

    $cmdLine = "scanstate.exe"
    $logFilename = "scan.log"
    $logFilePath = Join-Path -path $OutPath -ChildPath $logFilename
    $args = @($OutPath, "/i:$SettingsFilePath", "/l:$logFilePath", "/v:5 /c")
    Write-Host "  Calling scanstate...  Args:  $args"
    $starttime = Get-Date
    $exitCode = Start-Process -FilePath $cmdLine -ArgumentList $args -PassThru -Wait
    $endtime = Get-Date
    $span = New-TimeSpan -Start $starttime -End $endtime
    Write-Host "  ... completed (exit code:  {0})", $exitCode

    <# 
    # https://docs.microsoft.com/en-us/windows/configuration/configure-windows-10-taskbar
    $layoutPath = "userStartLayout.xml"
    $filepath = Join-Path -path $OutPath -ChildPath $layoutPath
    Write-Host "  Calling Export-StartLayout (filepath:  $filepath)"
    Export-StartLayout -Path $filepath
    Write-Host "  ... completed."
    #>

}
finally {
    Write-Host "  Elapsed time:  {0}", $span
    Pop-Location
}
