# Generation.psm1



<#
    .DESCRIPTION
    Returns a string of Powershell code to generate the files passed in $PathList.
    The generated files will be relative to the location of the generator script.
    .PARAMETER PathList
    List of file paths or directories with files.
#>
function Get-StringOfScriptGenerator(
    [string[]] $PathList,
    [System.Text.StringBuilder] $Content = $null,
    [switch] $Recurse
) {
    $scriptContentSB = $Content

    if ($null -eq $scriptContentSB)
    {
        $scriptContentSB = [System.Text.StringBuilder]::new("### This script was autogenerated and it generates files`n`n`n`n")
    }

    foreach ($path in $PathList)
    {
        if ((Get-Item $path).PSIsContainer)
        {
            $filesContentFromDirectory = (Get-ChildItem $path -File:(-not $Recurse)).FullName
            Get-StringOfScriptGenerator -PathList $filesContentFromDirectory -Content $scriptContentSB > $null -Recurse:$Recurse
        }
        else
        {
            $relativePath = ($path | Resolve-Path -Relative | Split-Path -NoQualifier).Replace('..', '.')
            $fileContent = (Get-Content $path -Raw).Replace('`', '``').Replace('$', '`$')
    
            $scriptContentSB.Append("New-Item -Path ""$relativePath"" ```n") > $null
            $scriptContentSB.Append("-Value @""`n") > $null
            $scriptContentSB.Append($fileContent) > $null
            $scriptContentSB.Append("`n""@```n") > $null
            $scriptContentSB.Append("-Force ```n") > $null
            $scriptContentSB.Append('-ErrorAction Ignore') > $null
            $scriptContentSB.Append("`n`n`n") > $null
        }
    }

    return $scriptContentSB.ToString()
}


function GetRelativeLocation(
    [string] $RelativeTo,
    [string] $Path
) {
    $currentLocation = Get-Location

    Set-Location $RelativeTo
    $relativePath = ($Path | Resolve-Path -Relative)
    Set-Location $currentLocation

    return $relativePath
}



Export-ModuleMember -Function *-*