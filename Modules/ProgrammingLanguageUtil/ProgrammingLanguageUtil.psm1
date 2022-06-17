# ProgrammingLanguageUtil.psm1



# From repository: https://github.com/ElianFabian/powershell-utils



<#
    .DESCRIPTION
    Given a file full with file paths returns an object that groups those file by their extension.

    .PARAMETER Path
    If $Path is a folder then it will get the paths of the files from that folder.
    If $Path is a file then it will get the paths from its content.
    If $Path is not specify then it gets the paths from the clipboard.

    .PARAMETER Recurse
    If $Path is a folder then you can get all the files' path recursely.

    .PARAMETER Relative
    If $Path is a folder the paths of the files will be relative to $Path directory.

    .PARAMETER RelativeTo
    If $Path is a folder the paths of the files will be relative to $RelativeTo directory.
#>
function Get-FilesObject-GroupBy-Extension
(
    [string] $Path,
    [switch] $Recurse,
    [switch] $Relative,
    [string] $RelativeTo = "."
) { 
    $filePaths   = ""
    $isFolder    = ""
    $filesObject = [ordered] @{} # Contains the files' path group by their extension

    if ($Path -ne $null) { $isFolder = (Get-Item $Path).PSIsContainer }

    if ($Path -eq $null)
    {
        $filePaths = Get-Clipboard
    }
    elseif ($isFolder)
    {
        $filePaths = (Get-ChildItem -Path $Path -File -Recurse:$Recurse).FullName

        if ($Relative)
        {
            $currentLocation = (Get-Location).Path

            Set-Location $RelativeTo
            $filePaths = ($filePaths | Resolve-Path -Relative )
            Set-Location $currentLocation
        }
    }
    else
    {
        $filePaths = Get-Content $Path
    }

    $filePaths | ForEach-Object {
        # $_ = "things\txtFiles\this is-my_text.file.txt" (This is for visual help. It's an example of the worst filename case)

        $itemArray    = $_.Split("/\") # ["things", "txtFiles", "this is-my_text.file.txt"]
        $itemFullName = $itemArray[-1] # "this is-my_text.file.txt"

        # This is in case you want to put just a list of strings in a file and just get an object with atributes and values without any kind of group
        if ($itemFullName.Contains("."))
        {
            $itemFullNameArray = $itemArray[-1].Split(".")               # ["this is-my_text", "file, txt"]
            $item_ext          = $itemFullNameArray[-1]                  # "txt"
            $item_name         = $itemFullName.Replace(".$item_ext", "") # this is-my_text.file

            # If the name starts with a number it adds a '_' to the beginning (variables can't start with a number)
            if ($item_name -match "^[0-9]") { $item_name = $item_name.Insert(0, "_") }

            $filesObject.hasExtension = $true
        }
        else
        {
            $item_name = $itemFullName
            $filesObject.hasExtension = $false
        }

        $item_name = $item_name.Replace(" ", "_") # "this_is-my_text.file"
        $item_name = $item_name.Replace("-", "_") # "this_is_my_text.file"
        $item_name = $item_name.Replace(".", "_") # "this_is_my_text_file"

        if ($itemFullName.Contains("."))
        {
            # If the extension doesn't exist in the object then we create it
            if (-Not $filesObject.Contains($item_ext))
            {
                $filesObject.$item_ext = @{}
            }

            # Adds the file name in the corresponding extension with its value
            $filesObject.$item_ext.$item_name = $_ # $filesObject.txt.textFile = "things\txtFiles\this is-my_text.file.txt"
        }
        else
        {
            $filesObject.$item_name = $_ # $filesObject.textFile = "things\txtFiles\this is-my_text.file.txt"
        }
    }

    return $filesObject
}

function Get-ClassFields
(
    [System.Object] $Items,
    [string]        $CurrentTab,
    [int]           $FieldTabSize,
    [string]        $Type
) {
	$SEMICOLON = ";"
	$body      = ""

    $fieldTab = $CurrentTab * $FieldTabSize

	foreach($filePath in $Items.GetEnumerator())
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

##### WARNING: this function doesn't yet work well when mixing files with extensions and files without extensions #####

<#
    .DESCRIPTION
    Given a file full with file paths returns a string of a class in the specified programming language that groups those file by their extension as subclasses.

    .PARAMETER Path
    If $Path is a folder then it will get the paths of the files from that folder.
    If $Path is a file then it will get the paths from its content.
    If $Path is not specify then it gets the paths from the clipboard.

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
    You have to add the $Relative parameter to use this parameter.
#>
function Get-FilesObject-InClassStructure
(
    [string]       $Path,
    [string]       $FieldType    = "String",
    [LanguageType] $LanguageType = [LanguageType]::CSharp,
    [int]          $TabSize      = 4,
    [switch]       $Recurse,
    [switch]       $Relative,
    [string]       $RelativeTo   = "."
) {
    $filesObject = Get-FilesObject-GroupBy-Extension -Path $Path -Recurse:$Recurse -Relative:$Relative -RelativeTo $RelativeTo

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

            $body += Get-ClassFields -Items $ext.Value -CurrentTab $tab -FieldTabSize 2 -Type $FieldType

            $body += "$tab}`n"
        }
    }
    else # If not we only have fields inside the class
    {
        $body = Get-ClassFields -Items $filesObject -CurrentTab $tab -FieldTabSize 1 -Type $FieldType
    }

    $body      = $body.Substring(0, $body.Length - 1) # Deletes the final escape character

    $strFiles += "$body`n"
    $strFiles += "}"

	return $strFiles
}



Export-ModuleMember `
    -Function `
        Get-FilesObject-GroupBy-Extension,
        Get-FilesObject-InClassStructure
