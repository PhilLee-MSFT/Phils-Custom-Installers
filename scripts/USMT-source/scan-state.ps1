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
        if (Test-Path -Path "$StatePath\USMT")
        {
            Write-Host "  Found existing machine state!  Renaming..."
            $newName =  "$StatePath\USMT" + (Get-Date -Format "-mss")
            Rename-Item -Path "$StatePath\USMT" -NewName $newName -Force
        }
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
        exit (22)
    }
}

################################################

$scriptdrive = Split-Path -Path $StatePath -Qualifier
$scriptroot = Join-Path -Path $scriptdrive -ChildPath "Phils-Custom-Installers\scripts\USMT-source"
$modroot = Join-Path -Path $scriptroot -ChildPath "StateHelpers.psm1"
Import-Module $modroot -Force

$settingsFilePath = Join-Path -Path $scriptroot -ChildPath $settingsFilename
Test-Params -StatePath $StatePath -SettingsFilePath $settingsFilePath

Control-State -Action "scan" -StatePath $StatePath -SettingsFilePath $settingsFilePath
