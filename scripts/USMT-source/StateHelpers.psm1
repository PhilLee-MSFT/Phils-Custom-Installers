function DownloadToFilePath ($downloadUrl, $targetFile)
{
    Write-Output ("Downloading installation files from URL: $downloadUrl to $targetFile")
    $targetFolder = Split-Path $targetFile

    if ((Test-Path -path $targetFile))
    {
        Write-Output "Deleting old target file $targetFile"
        Remove-Item $targetFile -Force | Out-Null
    }

    if (-not (Test-Path -path $targetFolder))
    {
        Write-Output "Creating folder $targetFolder"
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

    if ($downloadAttempts -eq 5)
    {
        Write-Error "Download of $downloadUrl failed repeatedly. Giving up."
    }
}


function Install-USMT
{
    # install the USMT...
    Write-host "Install-USMT..."

    $url = "https://go.microsoft.com/fwlink/?linkid=2026036"
    $localFile = ".\usmt_setup.exe"

    DownloadToFilePath -downloadUrl $url -targetFile $output
    $retCode = Start-Process -FilePath $localFile -Wait -PassThru

    if ($retCode.ExitCode -ne 0 -and $retCode.ExitCode -ne 3010)
    {
        throw "Product installation of $localFile failed with exit code: $($retCode.ExitCode.ToString())"    
    }
}
