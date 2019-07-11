[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string] $UserName
)

###################################################################################################
#
# PowerShell configurations
#
Set-StrictMode -Version 2.0

# NOTE: Because the $ErrorActionPreference is "Stop", this script will stop on first failure.
#       This is necessary to ensure we capture errors inside the try-catch-finally block.
$ErrorActionPreference = "Stop"

# Hide any progress bars, due to downloads and installs of remote components.
$ProgressPreference = "SilentlyContinue"

# Discard any collected errors from a previous execution.
$Error.Clear()

# Allow certain operations, like downloading files, to execute.
Set-ExecutionPolicy Bypass -Scope Process -Force


##################################################################################################
#
# Private helper methods
#

###################################################################################################
#
# Main execution block.
#
Remove-LocalGroupMember -Group 'Administrators' -Member $UserName
Remove-LocalUser -Name $UserName
