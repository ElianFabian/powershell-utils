# WebRequestModule.psm1



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
function Get-FileLinksFromWeb([string] $Uri, [switch] $Verbose)
{
    # If the Uri doesn't ends with a slash then we add it because it's supposed to be a folder,
    # ending with a slash it's what we use to differentiate between files and folders.
    if (-not $Uri.EndsWith("/"))
    {
        $Uri += "/"
    }

    $allLinksFromWebResponse = Invoke-WebRequest -Uri $Uri -Verbose:$Verbose

    $linkList = New-Object Collections.Generic.List[String]

    $linkCount = $allLinksFromWebResponse.Links.Count

    for ($i = 0; $i -lt $linkCount; $i++)
    {
        $currentLink = $allLinksFromWebResponse.Links.Item($i)

        $href = $currentLink.href

        $notFileOrFolderLinkCondition = ($href -match '[\?\=]') -or ($href -eq "/")

        if ($notFileOrFolderLinkCondition) { continue }

        $isFileOrFolderLink = [regex]::Matches($currentLink.outerHTML, $href).Count -eq 2

        if ($isFileOrFolderLink)
        {
            $linkList.Add("$Uri$($href)")
        }
    }

	return $linkList.AsReadOnly()
}

# This is the prive version of Invoke-DirectoryDownload, we have to define the other function in other to
# make the files be contained in the folder given in the Uri.
function Invoke-DirectoryDownload_WithoutContainingFolder
(
    [string] $Uri,
    [string] $Destination = "./",
    [switch] $Recurse ,
    [switch] $Verbose,
    [switch] $SkipHttpErrorCheck
) {
    $linkList = Get-FileLinksFromWeb -Uri $Uri -Verbose:$Verbose

    foreach($link in $linkList)
    {
        $isFolder = $link.EndsWith("/")

        # We assume that if the link ends with a slash it's a folder, if it doesn't end with a slash
        if ($isFolder)
        {
            $folderName = Split-Path -Path $link -Leaf

            $newDestination = Join-Path -Path $Destination -ChildPath $folderName

            $null = New-Item -Path $newDestination -ItemType Directory

            if ($Recurse)
            {
                try
                {
                    Invoke-DirectoryDownload_WithoutContainingFolder -Uri $link -Destination "$newDestination/" -Recurse:$Recurse -Verbose:$Verbose -SkipHttpErrorCheck:$SkipHttpErrorCheck
                }
                catch [System.Net.WebException]
                {
                    Write-Warning "$_`nRelated link: $link"
                }
                catch # In case the assumption is wrong we have to delete the folder we created and download the file
                {
                    Write-Warning "$_`nFile has no extension: $link"

                    Remove-Item -Path $newDestination -Recurse

                    $filename = $folderName

                    Invoke-WebRequest -Uri $link -OutFile $Destination/$filename -Verbose:$Verbose -SkipHttpErrorCheck:$SkipHttpErrorCheck
                }
            }
        }
        else
        {
            $filename = Split-Path -Path $link -Leaf

            Invoke-WebRequest -Uri $link -OutFile $Destination/$filename -Verbose:$Verbose -SkipHttpErrorCheck:$SkipHttpErrorCheck
        }
    }
}

<#
    .SYNOPSIS
    Gets content from a web page on the Internet of a folder explore type.

    .DESCRIPTION
    Downloads all the files and folders from a url inside the folder they are contained in a web page (for example a VPS).
#>
function Invoke-DirectoryDownload
(
    [string] $Uri,
    [string] $Destination = "./",
    [switch] $Recurse,
    [switch] $Verbose,
    [Alias("HideProgressBar")]
    [switch] $ForceFastDownload,
    [switch] $SkipHttpErrorCheck
){
    $rootFolderName = $Uri | Split-Path -Leaf
    $Destination    = Join-Path -Path $Destination -ChildPath $rootFolderName

    $null = New-Item -Path $Destination -ItemType Directory

    $currentProgressPreference = $ProgressPreference

    if ($ForceFastDownload)
    {
        $ProgressPreference = 'SilentlyContinue'

        Write-Verbose "Disable Progressbar because of ForceFastDownload (Hide ProgerssBar)" -Verbose

        if ($Verbose)
        {
            Write-Verbose "Disable Verbose because of ForceFastDownload (Hide ProgerssBar)" -Verbose
            $Verbose = $false
        }
    }

    Invoke-DirectoryDownload_WithoutContainingFolder -Uri $Uri -Destination $Destination -Recurse:$Recurse -Verbose:$Verbose -SkipHttpErrorCheck:$SkipHttpErrorCheck

    $ProgressPreference = $currentProgressPreference
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
    Invoke-DirectoryDownload,
    Invoke-FileContentExpression
