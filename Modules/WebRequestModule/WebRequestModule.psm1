# WebRequestModule.psm1



# From repository: https://github.com/ElianFabian/powershell-utils



<#
    .SYNOPSIS
    Gets all the file and folder links from a web page (like a VPS).

    .DESCRIPTION
    This method is supposed to be used to download files and folders in Get-FilesFromUri
    and to do so it's useful to know what is a folder and what is a file when we introduce a url
    it's going to be a folder which will contain more folders and files.

    .PARAMETER Uri
    The URI of the web page.
#>
function Invoke-FileLinksFromUri([string] $Uri, [switch] $Verbose)
{
    # If the Uri doesn't ends with a slash then we add it because it's supposed to be a folder,
    # ending with a slash it's what we use to differentiate between files and folders.
    if (-Not $Uri.EndsWith("/"))
    {
        $Uri += "/"
    }

    $allLinksFromWebResponse = Invoke-WebRequest -Uri $Uri -Verbose:$Verbose

    $linkList = New-Object Collections.Generic.List[String]

    $linkCount = $allLinksFromWebResponse.Links.Count

    0..($linkCount - 1) | ForEach-Object {

        $currentLink = $allLinksFromWebResponse.Links.Item($_)

        if ($currentLink.innerHTML -eq $currentLink.href) # The links we want satisfy this condition
        {
            $linkList.Add("$Uri$($currentLink.href)")
        }
    }

	return $linkList
}

# This is the prive version of Get-FilesFromUri, we have to define the other function in other to
# make the files be contained in the folder given in the Uri.
function Get-FilesFromUri-WithoutContainingFolder([string] $Uri, [string] $Destination = ".\", [switch] $Recurse , [switch] $Verbose)
{
    $links = Invoke-FileLinksFromUri -Uri $Uri -Verbose:$Verbose

    foreach($link in $links)
    {
        $splittedLink = $link.Split("/")

        $isFolder = $link.EndsWith("/")

        if ($isFolder)
        {
            $folderName = $splittedLink[$splittedLink.Length - 2]

            New-Item -Path "$Destination\$folderName\" -ItemType Directory

            if ($Recurse)
            {
                try
                {
                    Get-FilesFromUri-WithoutContainingFolder -Uri "$Uri$folderName/" -Destination "$Destination\$folderName\" -Recurse:$Recurse -Verbose:$Verbose
                }
                catch # This will be thrown if a file has no extension
                {
                    $fileName = $folderName

                    Write-Warning "The file '$Uri$fileName' has no extension."

                    Remove-Item -Path "$Destination\$fileName\"

                    Invoke-WebRequest -Uri $link -OutFile "$Destination\$fileName" -Verbose:$Verbose

                    continue
                }
            }
        }
        else
        {
            $fileName = $splittedLink[$splittedLink.Length - 1]

            Invoke-WebRequest -Uri $link -OutFile "$Destination\$fileName" -Verbose:$Verbose
        }
    }
}

<#
    .SYNOPSIS
    Gets content from a web page on the Internet (like a VPS).

    .DESCRIPTION
    Downloads all the files and folders from a url inside the folder they are contained in a web page (for example a VPS).

    .PARAMETER Uri
    The URI of the web page.

    .PARAMETER Destination
    The destination folder where the files will be downloaded, by default it's the current folder.

    .PARAMETER Recurse
    If present it downloads all the files from every single folder recursively.
#>
function Get-FilesFromUri([string] $Uri, [string] $Destination = ".\", [switch] $Recurse, [switch] $Verbose)
{
    $splittedUri    = $Uri.Split("/")
    $rootFolderName = $splittedUri[$splittedUri.Length - 2]

    $Destination += "$rootFolderName\"

    New-Item -Path $Destination -ItemType Directory

    Get-FilesFromUri-WithoutContainingFolder -Uri $Uri -Destination $Destination -Recurse:$Recurse -Verbose:$Verbose
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
    Get-FilesFromUri,
    Invoke-FileContentExpression
