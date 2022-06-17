# FileUtilModule.psm1



# From repository: https://github.com/ElianFabian/powershell-utils



<#
    .DESCRIPTION
    Converts an object into a string in properties file format.

    .PARAMETER PropertiesObject
    The object to convert into a string in properties file format.
#>
function ConvertTo-StringFileProperties([string] $PropertiesObject)
{
    $strProperties = ""

    foreach($key in $PropertiesObject.Keys)
    {
        $value = $PropertiesObject.$key

        $strProperties += "$key=$value`n"
    }

    return $strProperties
}

<#
    .DESCRIPTION
    Converts a string in properties file format into an object.

    .PARAMETER Path
    The path to the file containing the string in properties file format.
#>
function ConvertFrom-StringFileProperties([string] $Path)
{
    return Get-Content .\file.txt | ConvertFrom-StringData
}



<#
    .DESCRIPTION
    Copies the whole structure of a directory with the files, but empty (with 0 size).

    .PARAMETER Path
    The path of the directory to copy.

    .PARAMETER Destination
    The destination of the copy.
#>
function Copy-FolderStructure-WithEmptyFiles([string] $Path, [string] $Destination)
{
	$path_name = (Get-Item $Path).Name
	Get-ChildItem $Path -Directory -Recurse -Name | ForEach-Object { New-Item $Destination\$path_name\$_ -Type Directory }
    Get-ChildItem $Path -File      -Recurse -Name | ForEach-Object { New-Item $Destination\$path_name\$_ }
}


Export-ModuleMember -Function `
    ConvertTo-StringFileProperties,
    ConvertFrom-StringFileProperties,
    Copy-FolderStructure-WithEmptyFiles