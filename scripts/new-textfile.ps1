#*********
#
#   Install_AzCopy.ps1
#
#*********
Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

[int] $i = 0
do {
    $i++
    $fullpath = Join-Path -Path $env:TEMP -ChildPath "newfile$($i).txt"
} while (Test-Path -Path $fullpath)

New-Item -Path $fullpath