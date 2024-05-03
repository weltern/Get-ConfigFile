function Get-ConfigFile
{
    <#
    .SYNOPSIS
        Downloads/Copies over a config file from a remote location
    .DESCRIPTION
        Downloads/Copies over a config file from a remote location. Returns a file path location for the config file.
    .NOTES
        Author: Nick Welter
        Function Created: 04/17/2024
        Function Updated: 04/17/2024

        Currently supports only UNC paths or HTTP(S) paths
    .PARAMETER DownloadSource
        Either UNC Path or HTTP(S) path of the config file location. Ends with the filename and extention
    .PARAMETER Destination
        Location to place the downloaded config file. Ends with the filename and extention
    .EXAMPLE
        Get-ConfigFile -DownloadSource "\\Server\Test\Config.json" -Destination "C:\temp\config.json" -Verbose
        Attempts to Download/Copy over a config file from a remote location with Verbose logging.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [String]$DownloadSource,
        [Parameter(Mandatory = $true)]
        [String]$Destination
    )
    process
    {
        #Determine if download source is a URL or UNC path
        Write-Verbose -Message "Checking download source type"
        if ($DownloadSource -like "\\*")
        {
            $DownloadSourceType = "UNC"
            Write-Verbose -Message "Download source type: UNC"
        }
        elseif ($DownloadSource -like "http*")
        {
            $DownloadSourceType = "HTTP"
            Write-Verbose -Message "Download source type: HTTP"
        }
        else
        {
            Write-Error -Message "Unable to determine download source type. Please verify DownloadSource parameter."
            throw
        }

        #Test paths of Locations
        Write-Verbose -Message "Testing Path of Downloadsource"
        if ($DownloadSourceType -eq "UNC")
        {
            #UNC Test-Path
            if (-not(Test-Path -Path $DownloadSource -ErrorAction SilentlyContinue))
            {
                Write-Error -Message "Was unable to reach the DownloadSource: $DownloadSource. Please verify DownloadSource parameter."
                throw
            }
            else
            {
                Write-Verbose -Message "Verified DownloadSource location"
            }
        }
        else
        {
            #HTTP Test Path
            $certCallback = @"
using System;
using System.Net;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;
public class ServerCertificateValidationCallback
{
    public static void Ignore()
    {
        if(ServicePointManager.ServerCertificateValidationCallback ==null)
        {
            ServicePointManager.ServerCertificateValidationCallback += 
                delegate
                (
                    Object obj, 
                    X509Certificate certificate, 
                    X509Chain chain, 
                    SslPolicyErrors errors
                )
                {
                    return true;
                };
        }
    }
}
"@
            Add-Type $certCallback
            [ServerCertificateValidationCallback]::Ignore()
            if (-not((Invoke-WebRequest -Uri $DownloadSource -UseBasicParsing).Statuscode -eq 200))
            {
                Write-Error -Message "Was unable to reach the DownloadSource: $DownloadSource. Please verify DownloadSource parameter."
                throw
            }
            else
            {
                Write-Verbose -Message "Verified DownloadSource location"
            }
        }

        #Download the config file
        Write-Verbose -Message "Attemping to download the config file"
        if ($DownloadSourceType -eq "UNC")
        {
            #UNC Copy
            try
            {
                Copy-Item -Path $DownloadSource -Destination $Destination -Force -ErrorAction Stop
                $ConfigFileLocation = $Destination
                Write-Verbose -Message "ConfigFile successfully downloaded"
            }
            catch
            {
                Write-Error -Message "Download of Config file failed."
                throw
            }
        }
        else
        {
            #HTTP download
            try
            {
                Invoke-WebRequest -Uri $DownloadSource -OutFile $Destination -UseBasicParsing -ErrorAction Stop
                $ConfigFileLocation = $Destination
                Write-Verbose -Message "ConfigFile successfully downloaded"
            }
            catch
            {
                Write-Error -Message "Download of Config file failed."
                throw
            }
        }
    }
    end
    {
        if (Test-Path -Path $ConfigFileLocation -ErrorAction SilentlyContinue)
        {
            return $ConfigFileLocation
        }
        else
        {
            Write-Error -Message "Was unable to verify new config was sucessfully downloaded"
            throw
        }
    }
}
