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
    [String]$VMName
)


Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

#
# 0.  Load modules...
#
Import-Module -Name Az -RequiredVersion 2.5.0

#
# 1.  Get the data disk.
#
Write-Host " Getting the data disk"
$datadisk = Get-AzDisk -ResourceGroupName $DiskRGName -DiskName $DatadiskName

#
# 2.  Get the VM.  Make sure it's in a running state...
#
Write-Host " Getting the VM"
$vm = Get-AzVM -Name $VMName

#
# 3.  Detach the disk from the VM.
#
Write-Host "Detach the disk from the VM."
Remove-AzVMDataDisk -VM $vm -DataDiskNames $datadisk.Name
Update-AzVM -ResourceGroupName $vm.ResourceGroupName -VM $vm


Write-Host
Write-Host " All done." -ForegroundColor Green
Write-Host
