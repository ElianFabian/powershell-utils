# FileModule.psm1



# From repository: https://github.com/ElianFabian/powershell-utils



<#
    .DESCRIPTION
    Converts an object into a string in properties file format.

    .PARAMETER InputObject
    The object to convert into a string in properties file format.
#>
function ConvertTo-FileProperties([string] $InputObject)
{
    $strProperties = ""

    foreach ($key in $InputObject.Keys)
    {
        $value = $InputObject.$key

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
    return Get-Content $Path | ConvertFrom-StringData
}



<#
    .SYNOPSIS
    Creates an empty copy of a directory structure.

    .DESCRIPTION
    Creates a copy of the whole structure of a directory with the files, but empty (with 0 size).

    .PARAMETER Path
    The path of the directory to copy.

    .PARAMETER Destination
    The destination of the copy.
#>
function Copy-FolderStructure-WithEmptyFiles([string] $Path, [string] $Destination)
{
	$pathName = (Get-Item $Path).Name

	Get-ChildItem $Path -Directory -Recurse -Name | ForEach-Object { New-Item $Destination/$pathName/$_ -Type Directory }
    Get-ChildItem $Path -File      -Recurse -Name | ForEach-Object { New-Item $Destination/$pathName/$_ }
}

<#
    .SYNOPSIS
    Converts a given file into Unix format.

    .OUTPUTS
    None.
    When you use the PassThru parameter, `Set-Content` generates a System.String object that represents the content.
    Otherwise, this cmdlet does not generate any output.
#>
function ConvertTo-Unix([string] $Path, [switch] $PassThru)
{
    ((Get-Content $Path) -join "`n") + "`n" | Set-Content -NoNewline $Path -PassThru:$PassThru
}



Export-ModuleMember -Function `
    ConvertTo-FileProperties,
    ConvertFrom-StringFileProperties,
    Copy-FolderStructure-WithEmptyFiles,
    ConvertTo-Unix
