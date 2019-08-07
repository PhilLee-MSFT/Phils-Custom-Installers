[CmdletBinding()]
param
(
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
        Throw "Settings file does not exist - $SettingsFilePath"
    }
}

function Get-DriveLetter_Private()
{
    # get the data disk's drive letter...
    $diskpart = Get-Partition
    $datadrive = $diskpart | Where-Object { $_.DriveLetter -eq 'e' }
    if ($null -eq $datadrive) {
        $datadrive = $diskpart | Where-Object { $_.DriveLetter -eq 'f' }
    }
    return ($datadrive.DriveLetter +':')
}


################################################

$scriptdrive = Get-DriveLetter_Private
$StatePath = Join-Path -Path $scriptdrive -ChildPath "state"
$scriptroot = Join-Path -Path $scriptdrive -ChildPath "Phils-Custom-Installers\scripts\USMT-source"
$modroot = Join-Path -Path $scriptroot -ChildPath "StateHelpers.psm1"
Import-Module $modroot -Force

$settingsFilePath = Join-Path -Path $scriptroot -ChildPath $settingsFilename
Test-Params -StatePath $StatePath -SettingsFilePath $settingsFilePath

Control-State -Action "scan" -StatePath $StatePath -SettingsFilePath $settingsFilePath
