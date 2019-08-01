[CmdletBinding()]
param
(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]$InputString
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host $InputString