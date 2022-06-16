# WebRequestModule.psm1



<#
    .SYNOPSIS
    Gets all the file and folder links from a web page (like a VPS).

    .DESCRIPTION
    This method is supposed to be used to download files and folders with Invoke-FilesFromUri
    and to do so it's useful to know what is a folder and what is a file when we introduce a url
    it's going to be a folder which will contain more folders and files.

    .PARAMETER Uri
    The url of the web page.
#>
function Get-FileLinksFromUri($Uri)
{
    # If the Uri doesn't ends with a slash then we add it because it's supposed to be a folder
    # and ending with and slash it's what we use to differentiate between folders and files.
    if (-Not $Uri.EndsWith("/"))
    {
        $Uri += "/"
    }

    $webResponse = Invoke-WebRequest -Uri $Uri

    $elements = New-Object Collections.Generic.List[String]

    $nElements = $webResponse.Links.Count

    0..($nElements - 1) | ForEach-Object {

        $item = $webResponse.Links.Item($_)
        $innerHTML = $item.innerHTML

        if ($item.innerHTML -eq $item.href) # The links we want satisfy this condition
        {
            $elements.Add("$Uri$innerHTML")
        }
    }

	return $elements
}


# This is the prive version of Invoke-FilesFromUri, we have to define the other function in other to
# make the files be contained in the folder given in the Uri.
function Invoke-FilesFromUri-Without-ContainingFolder($Uri, $Destination = ".\")
    {
        $elements = Get-FileLinksFromUri -Uri $Uri

        $elements | ForEach-Object {

            $element_arr = $_.Split("/")

            if ($_.EndsWith("/"))
            {
                $element_name = $element_arr[$element_arr.Length - 2]

                New-Item -Path "$Destination\$element_name\" -ItemType Directory

                if ($Recurse)
                {
                    Invoke-FilesFromUri-Without-ContainingFolder "$Uri/$element_name/" "$Destination\$element_name\"
                }
            }
            else
            {
                $element_name = $element_arr[$element_arr.Length - 1]

                Invoke-WebRequest -Uri $_ -OutFile "$Destination$element_name"
            }
        }
    }

<#
    .SYNOPSIS
    Gets content from a web page on the Internet (like a VPS).

    .DESCRIPTION
    Downloads all the files and folders from a url inside the folder they are contained in a web page (for example a VPS).

    .PARAMETER Uri
    The url of the web page.

    .PARAMETER Destination
    The destination folder where the files will be downloaded, by default it's the current folder.

    .PARAMETER Recurse
    If present it downloads all the files from every single folder recursively.
#>
function Invoke-FilesFromUri($Uri, $Destination = ".\", [switch] $Recurse)
{
    $uriArr = $Uri.Split("/")
    $rootFolderName = $uriArr[$uriArr.Length - 2]

    $Destination += "$rootFolderName\"

    New-Item -Path $Destination -ItemType Directory

    Invoke-FilesFromUri-Without-ContainingFolder $Uri $Destination
}



<#
    .DESCRIPTION
    Executes the content of the file as powershell code from the given uri.
    To use this function you have to dot source it (insert a dot at the beginning of the function call).

    .PARAMETER Uri
    The url of the web page.
#>
function Invoke-FileContentExpression($Uri)
{
    Invoke-Expression (Invoke-WebRequest -Uri $Uri).Content
}



Export-ModuleMember -Function `
    Invoke-FilesFromUri,
    Invoke-FileContentExpression
