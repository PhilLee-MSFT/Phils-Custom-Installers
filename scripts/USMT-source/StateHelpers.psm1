function DownloadToFilePath ($downloadUrl, $targetFile)
{
    Write-Host ("Downloading installation files from URL: $downloadUrl to $targetFile")
    $targetFolder = Split-Path $targetFile

    if ((Test-Path -Path $targetFile))
    {
        Write-Host "Deleting old target file $targetFile"
        Remove-Item $targetFile -Force | Out-Null
    }

    if (-not (Test-Path -Path $targetFolder))
    {
        Write-Host "Creating folder $targetFolder"
        New-Item -ItemType Directory -Force -Path $targetFolder | Out-Null
    }

    # Download the file, with retries.
    $downloadAttempts = 0
    do
    {
        $downloadAttempts++

        try
        {
            $WebClient = New-Object System.Net.WebClient
            $WebClient.DownloadFile($downloadUrl,$targetFile)
            break
        }
        catch
        {
            Write-Output "Caught exception during download..."
            if ($_.Exception.InnerException)
            {
                Write-Output "InnerException: $($_.InnerException.Message)"
            }
            else
            {
                Write-Output "Exception: $($_.Exception.Message)"
            }
        }

    } while ($downloadAttempts -lt 5)

    if (Test-Path -Path $targetFile) {
        Write-Host "  Target file downloaded successfully - $targetfile" -ForegroundColor Green
    }
    elseif ($downloadAttempts -eq 5)
    {
        Write-Error "Download of $downloadUrl failed repeatedly. Giving up."
    }
    else {
        Write-Error "Something didn't work correctly.  We broke the loop but the download file DNE."
    }
}

function Install-USMT
{
    $usmtPath = "C:\\Program Files (x86)\\Windows Kits\\10\\Assessment and Deployment Kit\\User State Migration Tool\\amd64"

    if (Test-Path -Path (Join-Path -Path $usmtPath -ChildPath "scanstate.exe"))
    {
        Write-Host "  USMT installed..."
    }
    else
    {
        Write-Host "  Installing USMT..."

        $url = "https://go.microsoft.com/fwlink/?linkid=2026036"
        $targetFile = Join-Path -Path $env:temp -ChildPath "usmt_setup.exe"

        DownloadToFilePath -downloadUrl $url -targetFile $targetFile
        $logfile = Join-Path -Path $env:temp -ChildPath "usmt-install.log"
        $args = @("/quiet", "/log $logfile")
        $retCode = Start-Process -FilePath $targetFile -ArgumentList $args -Wait -PassThru

        if ($retCode.ExitCode -ne 0 -and $retCode.ExitCode -ne 3010)
        {
            throw "Product installation of $localFile failed with exit code: $($retCode.ExitCode.ToString())"    
        }
        else {
            Write-Host "  USMT installed successfully..." -ForegroundColor Green
        }
    }

    return $usmtPath
}

function Control-State($Action, $StatePath, $SettingsFilePath)
{
    Push-Location (Get-Location)
    $settingsFilename = Split-Path -Path $SettingsFilePath -Leaf

    try
    {
        # Insure the tools are installed...
        $usmtPath = Install-USMT    
        Set-Location $usmtPath
        
        # copy the custom settings file to the same directory as the default settings files...
        Copy-Item -Path $SettingsFilePath -Destination (Join-Path -Path $usmtPath -ChildPath $settingsFilename)

        if ($Action -eq 'scan')
        {
            $cmdLine = "scanstate.exe"
            $logFilePath = Join-Path -path $StatePath -ChildPath "scan.log"
            $args = @($StatePath, "/i:$settingsFileName", "/i:migapp.xml /v:5 /c", "/l:$logFilePath")
            Write-Host "  Calling scanstate...  Args:  $args"
        }
        else # Action == load...
        {
            $cmdLine = "loadstate.exe"
            $logFilePath = Join-Path -Path $StatePath -ChildPath "load.log"
            $args = @($StatePath, "/i:$settingsFilename", "/i:migapp.xml /v:5 /c /lac /lae", "/l:$logFilePath")
            Write-Host "  Calling loadstate...  Args:  $args"
        }

        $starttime = Get-Date
        $retCode = Start-Process -FilePath $cmdLine -ArgumentList $args -PassThru -Wait
        if ($retCode.ExitCode -ne 0)
        {
            throw "cmdline: $cmdLine failed with exit code: $($retCode.ExitCode.ToString())"    
        }
        else
        {
            Write-Host "  USMT completed" -ForegroundColor Green
        }

<#      # Haven't figured out how to get the "current user's" start layout when running from SP automation scripts...
        # for later...
        $layoutPath = "userStartLayout.xml"
        $filepath = Join-Path -path $StatePath -ChildPath $layoutPath
        if ($Action -eq 'scan')
        {
            # https://docs.microsoft.com/en-us/windows/configuration/configure-windows-10-taskbar
            Write-Host "  Calling Export-StartLayout (filepath:  $filepath)"
            Export-StartLayout -Path $filepath
            Write-Host "  ... completed."
        }
        else # Action == load
        {
            # https://blogs.technet.microsoft.com/deploymentguys/2016/03/07/windows-10-start-layout-customization/
            if (test-path $filepath) {
                set-location "$env:systemdrive\\"
                Write-Host "  Calling Import-StartLayout (filepath:  $filepath)"
                Import-StartLayout -LayoutPath $filepath -MountPath "$env:systemdrive\\"
                Write-Host "  ... completed."
            }
            else {
                Write-Host "  export file DNE:  $filepath" -ForegroundColor Red
            }
        }
 #>
 
    }
    finally
    {
        $endtime = Get-Date
        $span = New-TimeSpan -Start $starttime -End $endtime
        Write-Host "  Elapsed time:  $span"
        Pop-Location
    }
}
