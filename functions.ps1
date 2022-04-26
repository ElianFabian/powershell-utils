# functions.ps1

#region Is-Functions



#endregion

#region Copy-Functions

<#
    .DESCRIPTION
    # Copies the whole structure of a directory with the files, but empty (with 0 size).

    .PARAMETER Path
    # The path of the directory to copy.

    .PARAMETER Destination
    # The destination of the copy.
#>
function Copy-FolderStructure_WithEmptyFiles($Path, $Destination)
{
	$Path_name = (Get-Item $Path).Name
	Get-ChildItem $Path -Directory -Recurse -Name | ForEach-Object { New-Item $Destination\$Path_name\$_ -Type Directory }
    Get-ChildItem $Path -File      -Recurse -Name | ForEach-Object { New-Item $Destination\$Path_name\$_ }
}

#endregion

#region Get-Functions

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
function Get-FilesFromUri($Uri)
{
    # If the Uri doesn't ends with a slash, we add it because it's supposed to be a folder
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
        $inner = $item.innerHTML

        if ($inner -eq $item.href)
        {
            $elements.Add("$Uri$inner")
        }
    }

	return $elements
}

<#
    .DESCRIPTION
    Given a file full with file paths returns an object that groups those file by their extension.

    .PARAMETER Path
    If $Path is a folder then it will get the paths of the files from that folder.
    If $Path is a file then it will get the paths from its content.
    If $Path is not specify then it gets the paths from the clipboard.
#>
function Get-FilesObject_GroupBy_Extension($Path)
{
    $filePaths  = ""
    $fileObject = ""
    $isFolder   = ""

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

    $Files = [ordered] @{} # Contains the extensions of the files and each one contains the proper files path

    $filePaths | ForEach-Object {
        # $_ = "things\txtFiles\this is-my_text.file.txt" (This is for visual help. It's an example of the worst file name case) 

        $itemArr      = $_.Split("\") # ["things", "txtFiles", "this is-my_text.file.txt"]
        $itemFullName = $itemArr[-1]  # "this is-my_text.file.txt"

        # This is in case you want to put just a list of strings in a file and just get an object with atributes and values without any kind of group
        if ($itemFullName.Contains("."))
        {
            $itemFullNameArr = $itemArr[-1].Split(".") # ["this is-my_text", "file, txt"]
            $item_ext        = $itemFullNameArr[-1] # "txt"
            $item_name       = $itemFullName.Replace(".$item_ext", "")  # this is-my_text.file

            # If the name starts with a number it adds a '_' to the beginning
            if ($item_name -match "^[0-9]") { $item_name = $item_name.Insert(0, "_") }

            $Files.hasExtension = $true
        }
        else
        {
            $item_name = $itemFullName
            $Files.hasExtension = $false
        }
        $item_name = $item_name.Replace(" ", "_") # "this_is-my_text.file"
        $item_name = $item_name.Replace("-", "_") # "this_is_my_text.file"
        $item_name = $item_name.Replace(".", "_") # "this_is_my_text_file"

        if (-Not $itemFullName.Contains("."))
        {
            $Files.$item_name = $_ # $Files.textFile = "things\txtFiles\this is-my_text.file.txt"
        }
        else
        {
            # If the extension doesn't exist in the object then we create it
            if (-Not $Files.Contains($item_ext))
            {
                $Files.$item_ext = @{}
            }
            # Adds the file name in the corresponding extension with its value
            $Files.$item_ext.$item_name = $_ # $Files.txt.textFile = "things\txtFiles\this is-my_text.file.txt"
        }
    }
    return $Files
}

<#
    .DESCRIPTION
    Given a file full with file paths returns a string of a class in the specified programming language that groups those file by their extension as subclasses.

    .PARAMETER Path
    If $Path is a folder then it will get the paths of the files from that folder.
    If $Path is a file then it will get the paths from its content.
    If $Path is not specify then it gets the paths from the clipboard.

    .PARAMETER Type
    It's the type of the fields, by default it's "String".

    .PARAMETER LanguageType
    It's the programming language you want the class to be written, by default it's "CSharp".

    .PARAMETER TabSize
    It's the number of spaces you want to use to indent the code, by default it's 4.
#>
function Get-FilesObject_InClassStructureForm
(
    $Path,
    $Type = "String",
    [LanguageType] $LanguageType = [LanguageType]::CSharp,
    $TabSize = 4
) {
    $filesObject = Get-FilesObject_GroupBy_Extension $Path

    $tab = " " * $TabSize

    $hasExtension = $filesObject.hasExtension
    $filesObject.Remove("hasExtension") # Removes the hasExtension property because we don't want to add it to MyFiles class

    function Get-ClassFields($Items, $TabSize)
    {
        $SEMICOLON = ";"
        $body      = ""

        foreach($filePath in $Items.GetEnumerator())
        {
            $field = $filePath.Key
            $value = "`"$($filePath.Value.Replace("\", "\\"))`""
            $field_value = "$field = $value"

            $body += $tab * $TabSize
            $body += switch ($LanguageType)
            {
                CSharp { "public const $Type" }
                Java   { "public static final $Type" }
                Kotlin { "const val"; $SEMICOLON = "" }
            }
            $body += " "
            $body += "$field_value$SEMICOLON`n"
        }

        return $body
    }

    $container = switch ($LanguageType)
    {
        CSharp { "class" }
        Java   { "class" }
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
                Java { "public $container_extName" }
                Kotlin { "$container_extName" }
            }
            $body += "`n"
            $body += "$tab{`n"

            $body += Get-ClassFields -Items $ext.Value -TabSize 2

            # $body  = $body.Substring(0, $body.Length - 1) # Deletes the final escape character
            # $body += "`n"
            $body += "$tab}`n"
        }
    }
    else # If not we only have fields inside a class
    {
        $body = Get-ClassFields -Items $filesObject -TabSize 1
    }

    $body      = $body.Substring(0, $body.Length - 1) # Deletes the final escape character
    $strFiles += "$body`n"
    $strFiles += "}"

	return $strFiles
}

<#
    .DESCRIPTION
    Downloads all the files and folders from the given web page (like a VPS).

    .PARAMETER Uri
    The url of the web page.

    .PARAMETER Destination
    The destination folder where the files will be downloaded, by default it's the current folder.
#>
function Invoke-FilesFromUri($Uri, $Destination = ".\")
{
	$elements = Get-FilesFromUri -Uri $Uri

	$elements | ForEach-Object {

		$element_arr = $_.Split("/")

		if (-Not $_.EndsWith("/"))
		{
			$element_name = $element_arr[$element_arr.Length - 1]

			Invoke-WebRequest -Uri $_ -OutFile $Destination\$element_name
		}
		else 
		{
			$element_name = $element_arr[$element_arr.Length - 2]

			New-Item -Path "$Destination\$element_name\" -ItemType Directory
			Invoke-FilesFromUri "$Uri/$element_name/" "$Destination\$element_name\"
		}
	}
}

<#
    .DESCRIPTION
    # Downloads all the files and folders from a url inside the folder they are contained.

    .PARAMETER Uri
    The url of the web page.

    .PARAMETER Destination
    The destination folder where the files will be downloaded, by default it's the current folder.
#>
function Invoke-FilesFromUri_WithRootFolder($Uri, $Destination = ".\")
{
    $uriArr = $Uri.Split("/")
    $rootFolderName = $uriArr[$uriArr.Length - 2]

    $Destination += "$rootFolderName\"
    
    Invoke-FilesFromUri $Uri $Destination
}

#endregion


#region Watch Later

<#

function Rename-ItemAndPath($directory, $newName)
{
	if ( Is-DirectoryInPath($directory) )
	{
		Rename-Item $directory $newName

		[System.Environment]::SetEnvironmentVariable
		(
			'Path',
			$env:Path.Replace(
				$directory.Parent.FullName + $directory,
				$directory.Parent.FullName + $newName
			)
		)
		return $true
	}
	return $false
}

function Set-Properties(
    [parameter(ValueFromPipeline)] $inputObject,
    [hashtable] $properties,
    [switch] $passThru
) {
    process {
		foreach ($property in $result.PSObject.Properties)
        {
            $property.Name
        }
        Add-Member -InputObject $inputObject -NotePropertyMembers $properties -NotePropertyValue -force
        if ([bool]$passThru) { $inputObject }
		
		return $inputObject
    }
}

# <#
#     .DESCRIPTION
#     # Checks if a directory if in the Path variable.

#     .PARAMETER Path
#     # The directory to check.
# #>
# function Is-DirectoryInPath($Path)
# {
# 	if ( $env:Path.Contains("${Path.Parent.FullName}$Path\\") -match $true )
# 	{
# 		return $true
# 	}
# 	return $false
# }

#>

#endregion