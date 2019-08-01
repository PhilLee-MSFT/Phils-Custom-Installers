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
    [String]$SourceVMName
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
# 2.  Get the source VM.  Make sure it's in a running state...
#
Write-Host " Getting the source VM"
$sourceVM = Get-AzVM -Name $SourceVMName

#
# 3.  Detach the disk from the source VM.
#
Write-Host "Detach the disk from the source VM."
Remove-AzVMDataDisk -VM $sourceVM -DataDiskNames $datadisk.Name
Update-AzVM -ResourceGroupName $sourceVM.ResourceGroupName -VM $sourceVM


Write-Host " All done." -ForegroundColor Green
