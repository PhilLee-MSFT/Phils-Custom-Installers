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
# 1.  Get the disk.
#
Write-Host " Getting the disk"
$datadisk = Get-AzDisk -ResourceGroupName $DiskRGName -DiskName $DatadiskName

#
# 2.  Get the VM.
#
Write-Host " Getting the VM"
$vm = Get-AzVM -Name $VMName 

#
# 3.  Attach the disk to the VM.
#
Write-Host " Attach the disk to the VM"
Add-AzVMDataDisk -VM $vm -Name $datadisk.Name -CreateOption Attach -ManagedDiskId $datadisk.Id -Lun 1
Update-AzVM -ResourceGroupName $vm.ResourceGroupName -VM $vm

Write-Host
Write-Host " All done." -ForegroundColor Green
Write-Host