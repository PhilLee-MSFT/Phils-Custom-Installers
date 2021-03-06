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


###################################################################################################
#
# Main execution block.
#
try {
    # This will throw if AzureRM is not installed...
    Uninstall-AzureRm
}
# Might have a CommandNotFound if AzureRM is not installed...
catch [System.Management.Automation.CommandNotFoundException] {
    Write-Host "Caught CommandNotFound."
}
catch {
    $errorstring = $Error[0].Exception.Message
    Write-Host "Error:  $errorstring"
}
Write-Host "Installing NuGet and Az..."
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name Az -AllowClobber -Force
Import-Module PowerShellGet