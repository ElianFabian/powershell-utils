# Utils.ProgrammingLanguageModule.psm1



# From repository: https://github.com/ElianFabian/powershell-utils



<#
    .DESCRIPTION
    Given a file full with file paths returns an object that groups those file by their extension.

    .PARAMETER Path
    If it's a folder it will get the paths of the files from that folder.
    If it's a file it will get the paths from its content.

    .PARAMETER ListOfPaths
    Array of path files.
    (You could for example use it with Get-Clipboard.)

    .PARAMETER Recurse
    If $Path is a folder you can get all the files' path recursively.

    .PARAMETER Relative
    If $Path is a folder the paths of the files will be relative to $Path directory.

    .PARAMETER RelativeTo
    If $Path is a folder the paths of the files will be relative to $RelativeTo directory.
    $Relative parameter must be added in order to use this parameter.

    .OUTPUTS
    PSCustomObject
#>
function Get-FilesObjectGroupByExtension
(
    [string]   $Path,
    [string[]] $ListOfPaths,
    [switch]   $Recurse,
    [switch]   $Relative,
    [string]   $RelativeTo = "."
) { 
    $pathList    = @()
    $filesObject = [ordered] @{} # Contains the file paths group by their extension

    if ($ListOfPaths)
    {
        $pathList = $ListOfPaths

        if ($Path)
        {
            Write-Error "You can't use both Path and ListOfPaths parameters"
            return
        }
        if ($Recurse)
        {
            Write-Error "You can't use both Recurse and ListOfPaths parameters"
            return
        }
    }
    elseif (Test-Path $Path -PathType Container)
    {
        $pathList = (Get-ChildItem $Path -File -Recurse:$Recurse).FullName
    }
    else
    {
        $pathList = Get-Content $Path
    }

    if ($Relative)
    {
        $currentLocation = (Get-Location).Path

        Set-Location $RelativeTo
        $pathList = ($pathList | Resolve-Path -Relative )
        Set-Location $currentLocation
    }

    foreach ($filePath in $pathList)
    {
        # $filePath = "things/txtFiles/12this is-my_text.file.txt" (This is for visual help. It's an example of the worst filename case)

        $itemFullName  = Split-Path -Path $filePath -Leaf # "12this is-my_text.file.txt"
        $itemName      = ""
        $itemExtension = ""

        if ($itemFullName.Contains("."))
        {
            $itemExtension = $itemFullName.Split(".")[-1]                 # txt
            $itemName      = $itemFullName.Replace(".$itemExtension", "") # 12this is-my_text.file

            $filesObject.hasExtension = $true
        }
        else # In case you want a list of strings without grouping by extension (these strings wouldn't actually have an extension)
        {
            $itemName = $itemFullName
            $filesObject.hasExtension = $false
        }

        # Inserts an underscore to the variable name if it starts with a non-letter character
        $itemName = $itemName -replace '[^a-zA-Z]', '_' # _12this_is_my_text_file

        if ($itemFullName.Contains("."))
        {
            # If the extension doesn't exist yet in the object then we create it
            if (-not $filesObject.Contains($itemExtension))
            {
                $filesObject.$itemExtension = @{}
            }

            # Adds the filename in the corresponding extension with its value
            $filesObject.$itemExtension.$itemName = $filePath # $filesObject.txt._12this_is_my_text_file = "things/txtFiles/12this is-my_text.file.txt"
        }
        else
        {
            $filesObject.$itemName = $filePath # $filesObject._12this_is_my_text_file = "things/txtFiles/12this is-my_text.file.txt"
        }
    }

    return $filesObject
}

function Get-ClassFields
(
    [System.Object] $InputObject,
    [string]        $CurrentTab,
    [int]           $FieldTabSize,
    [string]        $Type
) {
	$SEMICOLON = ";"
	$body      = ""

    $fieldTab = $CurrentTab * $FieldTabSize

	foreach($filePath in $InputObject.GetEnumerator())
	{
		$field = $filePath.Key
		$value = "`"$($filePath.Value.Replace("\", "/"))`""

		$field_value = "$field = $value"

		$body += $fieldTab
		$body += switch ($LanguageType)
		{
			CSharp { "public const $Type"         }
			Java   { "public static final $Type"  }
			Kotlin { "const val"; $SEMICOLON = "" }
		}
		$body += " "
		$body += "$field_value$SEMICOLON`n"
	}

	return $body
}

<#
    .DESCRIPTION
    Given a file full with file paths returns a string of a class in the specified programming language
    that groups those file by their extension as subclasses.

    .PARAMETER Path
    If it's a folder it will get the paths of the files from that folder.
    If it's a file it will get the paths from its content.

    .PARAMETER ListOfPaths
    Array of path files.
    (You could for example use it with Get-Clipboard).

    .PARAMETER FieldType
    It's the type of the fields, by default it's "string".

    .PARAMETER LanguageType
    It's the programming language you want the class to be written, by default it's "CSharp".

    .PARAMETER TabSize
    It's the number of spaces you want to use to indent the code, by default it's 4.

    .PARAMETER Recurse
    If $Path is a folder then you can get all the files' path recursely.

    .PARAMETER Relative
    If $Path is a folder the paths of the files will be relative to the indicated directory.

    .PARAMETER RelativeTo
    If $Path is a folder the paths of the files will be relative to $RelativeTo directory.
    $Relative parameter must be added in order to use this parameter.

    .OUTPUTS
    String.
#>
function ConvertFrom-FilesObject
(
    [string]       $Path,
    [string[]]     $ListOfPaths,
    [string]       $FieldType    = "string",
    [LanguageType] $LanguageType = [LanguageType]::CSharp,
    [int]          $TabSize      = 4,
    [switch]       $Recurse,
    [switch]       $Relative,
    [string]       $RelativeTo   = "."
) {
    $filesObject = Get-FilesObjectGroupByExtension -Path $Path -ListOfPaths $ListOfPaths -Recurse:$Recurse -Relative:$Relative -RelativeTo $RelativeTo

    if ($null -eq $filesObject)
    {
        Write-Error "The files object is null"
        return
    }

    $tab = " " * $TabSize

    $hasExtension = $filesObject.hasExtension

    $filesObject.Remove("hasExtension") # Removes the hasExtension property because we don't want to add it to MyFiles class

    $container = switch ($LanguageType)
    {
        CSharp { "class"  }
        Java   { "class"  }
        Kotlin { "object" }
    }

    $strFiles += "$container MyFiles"
    $strFiles += "`n{`n"

    $body = ""

    if ($hasExtension) # If it has extension we have to group the files by their extension
    {
        foreach ($ext in $filesObject.GetEnumerator())
        {
            $container_extName = "$container $($ext.Name)" # public class txt

            $body += $tab
            $body += switch ($LanguageType)
            {
                CSharp { "public $container_extName" }
                Java   { "public $container_extName" }
                Kotlin { "$container_extName"        }
            }
            $body += "`n$tab{`n"

            $body += Get-ClassFields -InputObject $ext.Value -CurrentTab $tab -FieldTabSize 2 -Type $FieldType

            $body += "$tab}`n"
        }
    }
    else # If not we only have fields inside the class
    {
        $body = Get-ClassFields -InputObject $filesObject -CurrentTab $tab -FieldTabSize 1 -Type $FieldType
    }

    $body = $body.Substring(0, $body.Length - 1) # Deletes the final escape character

    $strFiles += "$body`n"
    $strFiles += "}"

	return $strFiles
}



Export-ModuleMember -Function Get-FilesObjectGroupByExtension
Export-ModuleMember -Function ConvertFrom-FilesObject
