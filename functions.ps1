# functions.ps1

#region Is-Functions

# Checks if a directory if in the Path variable
function Is-DirectoryInPath($directory)
{
	if ( $env:Path.Contains("${directory.Parent.FullName}$directory\\") -match $true )
	{
		return $true
	}
	return $false
}

#endregion

#region Copy-Functions

# Copies the whole structure of a directory, even the files, but empty
function Copy-FolderStructure_WithEmptyFiles($Path, $Destination)
{
	$Path_name = (Get-Item $Path).Name
	Get-ChildItem $Path -Directory -Recurse -Name | ForEach-Object { New-Item $Destination\$Path_name\$_ -Type Directory }
    Get-ChildItem $Path -File      -Recurse -Name | ForEach-Object { New-Item $Destination\$Path_name\$_ }
}

#endregion

#region Get-Functions

# Gets all the file and folder links from a url
function Get-FilesFromUri($Uri)
{
    # This method is supposed to be used to download files and folders with Invoke-FilesFromUri
    # and to do so it's useful to know what is a folder and what is a file
    # when we introduce a url it's going to be a folder which will contain more folders and files
    if (-Not $Uri.EndsWith("/"))
    {
        $Uri += "/"
    }
    
    $webResponse = Invoke-WebRequest -Uri $Uri # Curl

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

# Given a file full with file paths returns an object that groups those file by their extension
# If the Path is not specify then it gets the paths from the clipboard
# You can also use this function for a list of strings, it doesn't have to be a list of paths
function Get-FilesObject_GroupBy-Extension($Path)
{
    $filePaths = ""
    if ($Path -eq $null)
    {
        $filePaths = Get-Clipboard
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
# Gets an object return by the Get-Files-GroupBy-Extension-From-File function and return an string with the structure in a class c#/Java form
function Get-FilesObject_InClassStructureForm($Path, $Type = "String", [LanguageType] $LanguageType = [LanguageType]::CSharp)
{
    $Files = Get-FilesObject_GroupBy-Extension $Path

    $classTab    = "   "
    $attrTab     = "$classTab    "

    function Get-Body($items)
    {
        $body = ""

        foreach($filePath in $items.Value.GetEnumerator())
        {
            $body += switch ($LanguageType)
            {
                CSharp { "$attrTab public const $Type $($filePath.Key) = `"$($filePath.Value.Replace("\", "\\"))`";`n" }
                Java   { "$attrTab public static final $Type $($filePath.Key) = `"$($filePath.Value.Replace("\", "\\"))`";`n" }
                Kotlin { "$attrTab const val $($filePath.Name) = `"$($filePath.Value.Replace("\", "\\"))`"`n" }
            }
        }

        return $body
    }

    $dataType = switch ($LanguageType)
    {
        CSharp { "class" }
        Java   { "class" }
        Kotlin { "object" }
    }
    $strFiles += "$dataType MyFiles"
    $strFiles += "`n{`n"

    $body = ""

    if ($Files.hasExtension) # If it has extension we have to group the files by their extension
    { 
        $Files.Remove("hasExtension") # Removes the hasExtension property because we don't want to add it to MyFiles class

        foreach ($ext in $Files.GetEnumerator())
        {
            $body += switch ($LanguageType)
            {
                CSharp { "$classTab public $dataType $($ext.Name)" }
                Java { "$classTab public $dataType $($ext.Name)" }
                Kotlin { "$classTab $dataType $($ext.Name)" }
            }

            $body += "`n"
            $body += "$classTab {`n"

            $body += Get-Body $ext

            $body  = $body.Substring(0, $body.Length - 1) # Deletes the final escape character
            $body += "`n"
            $body += "$classTab }`n"
        }
    }
    else # If there's no extension then we don't have to group the files
    {
        $Files.Remove("hasExtension") # Removes the hasExtension property because we don't want to add it to MyFiles class
        $attrTab = $classTab          # Changes the tab length because if there are no group classes the attributes has a smaller tab length

        $body = Get-Body $Files
    }

    $body      = $body.Substring(0, $body.Length - 1) # Deletes the final escape character
    $strFiles += "$body`n"
    $strFiles += "}"

	return $strFiles
}

# Downloads all the files and folders from a url
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

# Downloads all the files and folders from a url inside the folder they are contained
function Invoke-FilesFromUri_WithRootFolder($Uri, $Destination = ".\")
{
    $uriArr = $Uri.Split("/")
    $rootFolderName = $uriArr[$uriArr.Length - 2]

    $Destination += "$rootFolderName\"
    
    Invoke-FilesFromUri $Uri $Destination
}

#endregion

<# function Set-Properties(
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
 #>


#region Watch Later

<# function Rename-ItemAndPath($directory, $newName)
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
} #>

#endregion