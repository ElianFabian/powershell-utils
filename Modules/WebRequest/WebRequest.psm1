# WebRequest.psm1



# From repository: https://github.com/ElianFabian/powershell-utils



# Links of interest:
# http://svn.apache.org/repos/asf/ (For testing purposes)



<#
    .SYNOPSIS
    Gets all the file and folder links from a web page (like a VPS).

    .DESCRIPTION
    This method is supposed to be used to download files and folders in Invoke-DirectoryDownload
    and to do so it's useful to know what is a folder and what is a file when we introduce a url
    it's going to be a folder which will contain more folders and files.

    .PARAMETER Uri
    The URI of the web page.
#>
function Get-FileLinks([string] $Uri, [switch] $Verbose)
{
    # If the Uri doesn't ends with a slash then we add it because it's supposed to be a folder,
    # ending with a slash it's what we use to differentiate between files and folders.
    if (-not $Uri.EndsWith("/"))
    {
        $Uri += "/"
    }

    $linksFromResponse = Invoke-WebRequest -Uri $Uri -Verbose:$Verbose

    $linkList = New-Object Collections.Generic.List[String]

    $linkCount = $linksFromResponse.Links.Count

    $innerHTMLRegex = '((?<=>)(.*?)(?=<))'

    for ($i = 0; $i -lt $linkCount; $i++)
    {
        $currentLink = $linksFromResponse.Links.Item($i)

        $href = $currentLink.href

        $innerHTML = (Select-String -InputObject $currentLink.outerHTML -Pattern $innerHTMLRegex).Matches.Value

        if ($null -eq $innerHTML) { continue }

        $isFileOrFolderLink = $href -eq $innerHTML

        if ($isFileOrFolderLink)
        {
            $linkList.Add("$Uri$href")
        }
    }

	return $linkList.AsReadOnly()
}

function Invoke-FileDownload([string] $Uri, [string] $OutFile, [switch] $SkipHttpErrorCheck, [switch] $ExtraVerbose)
{
    Write-Verbose "- Downloading $Uri..." -Verbose:$VerbosePreference

    Invoke-WebRequest -Uri $Uri -OutFile $OutFile -Verbose:$ExtraVerbose -SkipHttpErrorCheck:$SkipHttpErrorCheck

    Write-Verbose "- Downloaded $Uri" -Verbose:$VerbosePreference
}

# This is the prive version of Invoke-DirectoryDownload, we have to define the other function in other to
# make the files be contained in the folder given in the Uri.
function Invoke-DirectoryDownload_WithoutRootFolder
(
    [string] $Uri,
    [string] $Destination,
    [switch] $Recurse,
    [uint]   $Depth,
    [switch] $ExtraVerbose,
    [switch] $SkipHttpErrorCheck,
    [switch] $UseParallelDownload,
    [int]    $ThrottleLimit
) {
    if (-not $UseParallelDownload) { $ThrottleLimit = 1 }

    $getFileLinksFunction = ${function:Get-FileLinks}.ToString()
    $invokeDirectoryDownload_WithoutRootFolderFunction = ${function:Invoke-DirectoryDownload_WithoutRootFolder}.ToString()
    $invokeFileDownloadFunction = ${function:Invoke-FileDownload}.ToString()

    $linkList = Get-FileLinks -Uri $Uri -Verbose:$ExtraVerbose

    $linkList | ForEach-Object -ThrottleLimit $ThrottleLimit -Parallel { $link = $_

        ${function:Get-FileLinks}       = $using:getFileLinksFunction
        ${function:Invoke-FileDownload} = $using:invokeFileDownloadFunction
        ${function:Invoke-DirectoryDownload_WithoutRootFolder} = $using:invokeDirectoryDownload_WithoutRootFolderFunction

        $isFolder = $link.EndsWith("/")

        # We assume that the link ends with a slash if it's a folder, if it doesn't end with a slash
        if ($isFolder)
        {
            $folderName = Split-Path -Path $link -Leaf
            $newFolder  = Join-Path -Path $using:Destination -ChildPath $folderName

            New-Item -Path $newFolder -ItemType Directory > $null

            if (-not $using:Recurse -and $using:Depth -eq 0) { continue }

            if ($using:Recurse -or $using:Depth -ge 0)
            {
                try
                {
                    $newDepth = $using:Depth - 1
                    if ($newDepth -lt 0) { $newDepth = 0 }

                    Invoke-DirectoryDownload_WithoutRootFolder -Uri $link -Destination "$newFolder/" -Depth $newDepth @using:PSBoundParameters
                }
                catch [System.Net.WebException] {}
                catch [System.Net.Sockets.SocketException] {}
                catch [System.Management.Automation.RemoteException] {}
                catch # In case the assumption is wrong we have to delete the folder we created and download the file
                {
                    if ($_.Exception.Response.StatusCode -eq [System.Net.HttpStatusCode]::InternalServerError)
                    {
                        Write-Warning "$($_.Exception.Message)`nRelated link: $link"
                        continue 
                    }

                    Write-Warning "$_`nFile has no extension: $link"

                    Remove-Item -Path $newFolder -Recurse

                    $filename = $folderName

                    Invoke-FileDownload -Uri $link -OutFile $using:Destination/$filename @using:PSBoundParameters
                }
            }
        }
        else
        {
            $filename = Split-Path -Path $link -Leaf

            Invoke-FileDownload -Uri $link -OutFile $using:Destination/$filename @using:PSBoundParameters
        }
    }

    Start-Sleep -Milliseconds 1
}

<#
    .SYNOPSIS
    Gets content from a web page on the Internet of a folder explore type.

    .DESCRIPTION
    Downloads all the files and folders from a url inside the folder they are contained in a web page (for example a VPS).
#>
function Invoke-DirectoryDownload
(
    [Parameter(Mandatory)]
    [string] $Uri,
    [string] $Destination = "./",
    [switch] $Recurse,

    [uint]   $Depth,
    [switch] $ExtraVerbose,

    [Alias("HideProgressBar")]
    [switch] $ForceFastDownload,
    [switch] $SkipHttpErrorCheck,
    [switch] $UseParallelDownload,
    [int]    $ThrottleLimit = 5
) {
    $rootFolder       = $Uri | Split-Path -Leaf
    $directoryFromUri = Join-Path -Path $Destination -ChildPath $rootFolder

    New-Item -Path $directoryFromUri -ItemType Directory > $null

    $currentProgressPreference = $ProgressPreference

    if ($ForceFastDownload)
    {
        $ProgressPreference = 'SilentlyContinue'

        Write-Verbose "Disable Progressbar because of ForceFastDownload (Hide ProgressBar)" -Verbose:$VerbosePreference

        if ($VerbosePreference -or $ExtraVerbose)
        {
            Write-Verbose "Disable Verbose because of ForceFastDownload" -Verbose:$VerbosePreference
            $VerbosePreference = $false
            $ExtraVerbose      = $false
        }
    }

    Invoke-DirectoryDownload_WithoutRootFolder -Destination $directoryFromUri -ThrottleLimit $ThrottleLimit @PSBoundParameters

    $ProgressPreference = $currentProgressPreference
}



<#
    .DESCRIPTION
    Executes the content of the file as powershell code from the given uri.
    To use this function you have to dot source it (insert a dot at the beginning of the function call).
#>
function Invoke-FileContentExpression([string] $Uri)
{
    Invoke-Expression (Invoke-WebRequest -Uri $Uri).Content
}



Export-ModuleMember -Function Invoke-DirectoryDownload
Export-ModuleMember -Function Invoke-FileContentExpression
