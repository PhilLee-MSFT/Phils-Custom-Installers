[CmdletBinding()]
param
(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]$Filename
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

New-Item -Path $Filename
