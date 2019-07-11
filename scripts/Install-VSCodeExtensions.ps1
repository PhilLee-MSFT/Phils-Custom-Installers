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
# Functions...
#
function install-extension([string] $extname)
{
    # https://code.visualstudio.com/docs/editor/command-line
    $cmdline = "C:\\Program Files\\Microsoft VS Code\\bin\\code.cmd"
    $args = @("--install-extension $extname", "--force")
    $retCode = Start-Process $cmdline -ArgumentList $args -wait
    if ($null -ne $retCode -and $retCode.ExitCode -ne 0 -and $retCode.ExitCode -ne 3010)
    {
        throw "Failed to install $extname with exit code: $($retCode.ExitCode.ToString())"    
    }
    else {
        Write-Host "  $extname installed successfully..." -ForegroundColor Green
    }
}

###################################################################################################
#
# Main execution block.
#
try {
    $extensions = @("streetsidesoftware.code-spell-checker",
                    "ms-vscode.csharp",
                    "docsmsft.docs-yaml",
                    "stuart.unique-window-colors",
                    "oderwat.indent-rainbow"
                    "ms-vscode.powershell",
                    "ms-python.python")

    foreach($extname in $extensions)
    {
        Write-Host "  Installing VS Code extension - $extname."
        install-extension $extname
    }
}

<# Might have a CommandNotFound if AzureRM is not installed...
catch [System.Management.Automation.CommandNotFoundException] {
    Write-Host "Caught CommandNotFound."
}#>

catch {
    $errorstring = $Error[0].Exception.Message
    Write-Host "Error:  $errorstring"
}
