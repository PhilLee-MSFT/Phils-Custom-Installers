[CmdletBinding()]
param
(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]$StatePath,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]$settingsFilename
)


Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

################################################
function Test-Params($StatePath, $SettingsFilePath)
{
    # test the incoming paths...
    if (Test-Path -Path $StatePath)
    {
        Write-Host "  StatePath exists - $StatePath"
    }
    else
    {
        Write-Host "  StatePath DNE - $StatePath.  Creating... " -ForegroundColor Yellow
        New-Item -Path $StatePath -ItemType Directory
    }
    if (Test-Path -Path $SettingsFilePath)
    {
        Write-Host "  Settings file exists - $SettingsFilePath"
    }
    else
    {
        Write-Host "  Settings file does not exist - $SettingsFilePath" -ForegroundColor Red
        exit (-1)
    }
}

################################################

$scriptroot = $PSScriptRoot
$modroot = Join-Path -Path $scriptroot -ChildPath "StateHelpers.psm1"
Import-Module $modroot -Force

$settingsFilePath = Join-Path -Path $scriptroot -ChildPath $settingsFilename
Test-Params -StatePath $StatePath -SettingsFilePath $settingsFilePath

Control-State -Action "scan" -StatePath $StatePath -SettingsFilePath $settingsFilePath
