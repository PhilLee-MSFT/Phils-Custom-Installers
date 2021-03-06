#
#
#
[CmdletBinding()]
param
(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]$DatadiskName,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]$DiskRGName,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]$SourceVMName,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]$DestinationVMName,

    [Parameter(Mandatory=$false)]
    [switch]$RunTest = $false,

    [Parameter(Mandatory=$false)]
    [switch]$LoadOnly,

    [Parameter(Mandatory=$false)]
    [switch]$ScanOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

#
# 0.  Load modules...
#
Write-Host "  Importing Az module..."
Import-Module -Name Az -RequiredVersion 2.5.0

#
# 1.  Get the data disk.
#
Write-Host " Getting the data disk"
$datadisk = Get-AzDisk -ResourceGroupName $DiskRGName -DiskName $DatadiskName

#
# Sometimes I only want to load the state on the destination machine.  If that's set, don't
# mess with scanning state on the source machine - we've probably already done that...
#
if ($LoadOnly -eq $true) {
    Write-Host "  LoadOnly set - skipping scanstate..."
}
else {
    #
    # 2.  Get the source VM.  Make sure it's in a running state...
    #
    Write-Host " Getting the source VM"
    $sourceVM = Get-AzVM -Name $SourceVMName 

    #
    # 3.  Attach the transfer disk to the source VM.
    #
    Write-Host " Attach the transfer disk to the source VM"
    Add-AzVMDataDisk -VM $sourceVM -Name $datadisk.Name -CreateOption Attach -ManagedDiskId $datadisk.Id -Lun 1
    Update-AzVM -ResourceGroupName $sourceVM.ResourceGroupName -VM $sourceVM

    #
    # 4.  Run the USMT on the source VM - the script is on the datadisk...
    #
    if ($RunTest -eq $true) {
        Write-Host " Run test script on the source VM."
        $filename = "Hello-" + (Get-Date -Format dss) + ".txt"
        $params = @{Filename = $filename}
        $scriptpath = ".\New-File.ps1"
        Invoke-AzVMRunCommand -ResourceGroupName $sourceVM.ResourceGroupName -Name $sourceVM.Name -CommandId 'RunPowerShellScript' -ScriptPath $scriptpath -Parameter $params
    }
    Write-Host " Run the USMT on the source VM."
    $params = @{settingsFilename = "config.xml"}
    $scriptpath = ".\scan-state.ps1"
    Invoke-AzVMRunCommand -ResourceGroupName $sourceVM.ResourceGroupName -Name $sourceVM.Name -CommandId 'RunPowerShellScript' -ScriptPath $scriptpath -Parameter $params

    #
    # 5.  Detach the disk from the source VM.
    #
    Write-Host "Detach the disk from the source VM."
    Remove-AzVMDataDisk -VM $sourceVM -DataDiskNames $datadisk.Name
    Update-AzVM -ResourceGroupName $sourceVM.ResourceGroupName -VM $sourceVM
}

#
# Sometimes I only want to scan the source machine.  If that's set, don't
# mess with loading on the destination machine...
#
if ($ScanOnly -eq $true) {
    Write-Host "  ScanOnly set - skipping loadstate..."
}
else {        
    #
    # 6.  Get the get the destination VM.  Make sure it's in a running state...
    #
    Write-Host " Get the destination VM"
    $destVM = Get-AzVM -Name $DestinationVMName

    #
    # 7.  Attach the transfer disk to the destination VM.
    #
    Write-Host " Attach the transfer disk to the destination VM"
    Add-AzVMDataDisk -VM $destVM -Name $datadisk.Name -CreateOption Attach -ManagedDiskId $datadisk.Id -Lun 1
    Update-AzVM -ResourceGroupName $destVM.ResourceGroupName -VM $destVM

    #
    # 8.  Write the state on the destination VM.
    #
    if ($RunTest -eq $true) {
        Write-Host " Run test script on the destination VM."
        $filename = "Hello-" + (Get-Date -Format dss) + ".txt"
        $params = @{Filename = $filename}
        $scriptpath = ".\New-File.ps1"
        Invoke-AzVMRunCommand -ResourceGroupName $destVM.ResourceGroupName -Name $destVM.Name -CommandId 'RunPowerShellScript' -ScriptPath $scriptpath -Parameter $params
    }

    Write-Host " Run the USMT on the destination VM."
    $params = @{settingsFilename = "config.xml"}
    $scriptpath = ".\write-state.ps1"
    Invoke-AzVMRunCommand -ResourceGroupName $destVM.ResourceGroupName -Name $destVM.Name -CommandId 'RunPowerShellScript' -ScriptPath $scriptpath -Parameter $params

    #
    # 9.  Detach the disk from the destination VM.
    #
    Write-Host " Detach the disk from the destination VM."
    Remove-AzVMDataDisk -VM $destVM -DataDiskNames $datadisk.Name
    Update-AzVM -ResourceGroupName $destVM.ResourceGroupName -VM $destVM
}


Write-Host
Write-Host " All done." -ForegroundColor Green
Write-Host
