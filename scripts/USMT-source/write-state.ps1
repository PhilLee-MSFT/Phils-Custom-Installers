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
        Write-Host "  State file exists - $StatePath"
    }
    else
    {
        Write-Error "  State file not found ($StatePath)" -ForegroundColor Red
        exit (-1)
    }
    if (Test-Path -Path $SettingsFilePath)
    {
        Write-Host "  Settings file exists - $SettingsFilePath"
    }
    else
    {
        Write-Error "  Settings file does not exist - $SettingsFilePath" -ForegroundColor Red
        exit (-1)
    }
}

################################################

$scriptroot = $PSScriptRoot
$modroot = Join-Path -Path $scriptroot -ChildPath "StateHelpers.psm1"
Import-Module $modroot -Force

$settingsFilePath = Join-Path -Path $scriptroot -ChildPath $settingsFilename
Test-Params -StatePath $StatePath -SettingsFilePath $settingsFilePath

Control-State -Action "load" -StatePath $StatePath -SettingsFilePath $settingsFilePath
