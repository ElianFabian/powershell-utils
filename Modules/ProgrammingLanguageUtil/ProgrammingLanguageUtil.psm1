# ProgrammingLanguageUtil.psm1



<#
    .DESCRIPTION
    Given a file full with file paths returns an object that groups those file by their extension.

    .PARAMETER Path
    If $Path is a folder then it will get the paths of the files from that folder.
    If $Path is a file then it will get the paths from its content.
    If $Path is not specify then it gets the paths from the clipboard.
#>
function Get-FilesObject-GroupBy-Extension($Path)
{
    $filePaths   = ""
    $isFolder    = ""
    $filesObject = [ordered] @{} # Contains the extensions of the files and each one contains the proper files path

    if ($Path -ne $null) { $isFolder = (Get-Item $Path).PSIsContainer }

    if ($Path -eq $null)
    {
        $filePaths = Get-Clipboard
    }
    elseif ($isFolder)
    {
        $filePaths = (Get-ChildItem $Path -File).FullName
    }
    else
    {
        $filePaths = Get-Content $Path
    }

    $filePaths | ForEach-Object {
        # $_ = "things\txtFiles\this is-my_text.file.txt" (This is for visual help. It's an example of the worst filename case)

        $itemArr      = $_.Split("/\") # ["things", "txtFiles", "this is-my_text.file.txt"]
        $itemFullName = $itemArr[-1]  # "this is-my_text.file.txt"

        # This is in case you want to put just a list of strings in a file and just get an object with atributes and values without any kind of group
        if ($itemFullName.Contains("."))
        {
            $itemFullNameArr = $itemArr[-1].Split(".") # ["this is-my_text", "file, txt"]
            $item_ext        = $itemFullNameArr[-1] # "txt"
            $item_name       = $itemFullName.Replace(".$item_ext", "") # this is-my_text.file

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

function Get-ClassFields($Items, $TabSize)
    {
        $SEMICOLON = ";"
        $body      = ""

        foreach($filePath in $Items.GetEnumerator())
        {
            $field = $filePath.Key
            $value = "`"$($filePath.Value.Replace("\", "/"))`""
            $field_value = "$field = $value"

            $body += $tab * $TabSize
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
    Given a file full with file paths returns a string of a class in the specified programming language that groups those file by their extension as subclasses.

    .PARAMETER Path
    If Path is a folder then it will get the paths of the files from that folder.
    If Path is a file then it will get the paths from its content.
    If Path is not specify then it gets the paths from the clipboard.

    .PARAMETER Type
    It's the type of the fields, by default it's "String".

    .PARAMETER LanguageType
    It's the programming language you want the class to be written, by default it's "CSharp".

    .PARAMETER TabSize
    It's the number of spaces you want to use to indent the code, by default it's 4.
#>
function Get-FilesObject-InClassStructure
(
    $Path,
    $Type = "String",
    [LanguageType] $LanguageType = [LanguageType]::CSharp,
    $TabSize = 4
) {
    $filesObject = Get-FilesObject-GroupBy-Extension $Path

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
            $container_extName = "$container $($ext.Name)" # class txt

            $body += $tab
            $body += switch ($LanguageType)
            {
                CSharp { "public $container_extName" }
                Java   { "public $container_extName" }
                Kotlin { "$container_extName"        }
            }
            $body += "`n"
            $body += "$tab{`n"

            $body += Get-ClassFields -Items $ext.Value -TabSize 2

            $body += "$tab}`n"
        }
    }
    else # If not we only have fields inside the class
    {
        $body = Get-ClassFields -Items $filesObject -TabSize 1
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