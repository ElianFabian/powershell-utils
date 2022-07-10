# WebRequestModule.psm1



# From repository: https://github.com/ElianFabian/powershell-utils


# Links of interest:
# http://svn.apache.org/repos/asf/ (For testing purposes)


<#
    .SYNOPSIS
    Gets all the file and folder links from a web page (like a VPS).

    .DESCRIPTION
    This method is supposed to be used to download files and folders in Invoke-DownloadFilesFromWeb
    and to do so it's useful to know what is a folder and what is a file when we introduce a url
    it's going to be a folder which will contain more folders and files.

    .PARAMETER Uri
    The URI of the web page.
#>
function Invoke-FileLinksFromUri([string] $Uri, [switch] $Verbose)
{
    # If the Uri doesn't ends with a slash then we add it because it's supposed to be a folder,
    # ending with a backslash it's what we use to differentiate between files and folders.
    if (-Not $Uri.EndsWith("/"))
    {
        $Uri += "/"
    }

    $allLinksFromWebResponse = Invoke-WebRequest -Uri $Uri -Verbose:$Verbose

    $linkList = New-Object Collections.Generic.List[String]

    $linkCount = $allLinksFromWebResponse.Links.Count

    for ($i = 0; $i -lt $linkCount; $i++)
    {
        $currentLink = $allLinksFromWebResponse.Links.Item($i)

        if ($currentLink.innerHTML -eq $currentLink.href) # The links we want satisfy this condition
        {
            $linkList.Add("$Uri$($currentLink.href)")
        }
    }

	return $linkList.AsReadOnly()
}

# This is the prive version of Invoke-DownloadFilesFromWeb, we have to define the other function in other to
# make the files be contained in the folder given in the Uri.
function Invoke-DownloadFilesFromWeb_WithoutContainingFolder
(
    [string] $Uri,
    [string] $Destination = "./",
    [switch] $Recurse ,
    [switch] $Verbose
) {
    $linkList = Invoke-FileLinksFromUri -Uri $Uri -Verbose:$Verbose

    foreach($link in $linkList)
    {
        $isFolder = $link.EndsWith("/")

        if ($isFolder)
        {
            $folderName = $link | Split-Path -Leaf

            $null = New-Item -Path "$Destination/$folderName" -ItemType Directory

            if ($Recurse)
            {
                try
                {
                    Invoke-DownloadFilesFromWeb_WithoutContainingFolder -Uri $link -Destination "$Destination/$folderName/" -Recurse:$Recurse -Verbose:$Verbose
                }
                catch [System.Net.WebException]
                {
                    Write-Warning "$_`nRelated link: $link"
                }
                catch # This will be thrown if a file has no extension
                {
                    Write-Warning "$_`nFile has no extension: $link"

                    Remove-Item -Path "$Destination/$folderName/" -Recurse

                    $fileName = $folderName

                    Invoke-WebRequest -Uri $link -OutFile "$Destination/$fileName" -Verbose:$Verbose
                }
            }
        }
        else
        {
            $fileName = Split-Path $link -Leaf

            Invoke-WebRequest -Uri $link -OutFile "$Destination/$fileName" -Verbose:$Verbose
        }
    }
}

<#
    .SYNOPSIS
    Gets content from a web page on the Internet of a folder explore type.

    .DESCRIPTION
    Downloads all the files and folders from a url inside the folder they are contained in a web page (for example a VPS).
#>
function Invoke-DownloadFilesFromWeb
(
    [string] $Uri,
    [string] $Destination = "./",
    [switch] $Recurse,
    [switch] $Verbose,
    [switch] $ForceFastDownload
){
    $rootFolderName = $Uri | Split-Path -Leaf
    
    $Destination = Join-Path -Path $Destination -ChildPath $rootFolderName

    $null = New-Item -Path $Destination -ItemType Directory

    $previousProgressPreference = $ProgressPreference

    if ($ForceFastDownload)
    {
        $ProgressPreference = 'SilentlyContinue'

        Write-Verbose "Disable Progressbar because of ForceFastDownload" -Verbose

        if ($Verbose)
        {
            Write-Verbose "Disable Verbose because of ForceFastDownload" -Verbose
            $Verbose = $false
        }
    }

    Invoke-DownloadFilesFromWeb_WithoutContainingFolder -Uri $Uri -Destination $Destination -Recurse:$Recurse -Verbose:$Verbose

    $ProgressPreference = $previousProgressPreference
}



<#
    .DESCRIPTION
    Executes the content of the file as powershell code from the given uri.
    To use this function you have to dot source it (insert a dot at the beginning of the function call).

    .PARAMETER Uri
    The URI of the web page.
#>
function Invoke-FileContentExpression([string] $Uri)
{
    Invoke-Expression (Invoke-WebRequest -Uri $Uri).Content
}



Export-ModuleMember -Function `
    Invoke-DownloadFilesFromWeb,
    Invoke-FileContentExpression
