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
function Add-RandomCharacterFromSet_Private([string] $original, [string] $characterSet)
{
    $location = Get-Random -Minimum 0 -Maximum (($original.Length) - 1)
    $char = $characterSet.ToCharArray() | Get-Random

    $new = $original.Insert($location, $char)

    return $new
}

function Get-VmPassword_Private
{
    #Password is 123 characters long, and meets the following requirements:
    # 8 - 123 chars
    # Uppercase char
    # Lowercase char
    # Number
    # Special char

    $lowercaseSet = "abcdefghijklmnopqrstuvwxyz"
    $uppercaseSet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    $numberSet = "0123456789"
    $specialSet = "!@#$%^&*()_+-=,./<>?[]\{}|"
    $allSet = $lowercaseSet + $uppercaseSet + $numberSet + $specialSet

    $password = ""

    for($charIx = 0; $charIx -le 12; $charIx++)
    {
        $password += $allSet.ToCharArray() | Get-Random
    }

    # make sure there is at least one character from each set at random positions
    $password = Add-RandomCharacterFromSet_Private -original $password -characterSet $lowercaseSet
    $password = Add-RandomCharacterFromSet_Private -original $password -characterSet $uppercaseSet
    $password = Add-RandomCharacterFromSet_Private -original $password -characterSet $numberSet
    $password = Add-RandomCharacterFromSet_Private -original $password -characterSet $specialSet

    return $password
}


###################################################################################################
#
# Main execution block.
#
$pwd = Get-VmPassword_Private
[SecureString] $secure = ConvertTo-SecureString -String $pwd -AsPlainText -Force
New-LocalUser -Name $UserName -Password $secure
Add-LocalGroupMember -Group 'Administrators' -Member $UserName

Write-Host " Done:  $UserName's pwd is $pwd"