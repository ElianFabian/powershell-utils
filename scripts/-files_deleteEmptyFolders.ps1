# files_deleteEmptyFolderes.ps1

#Deletes all the empty subfolders from current directory

# What's the top level directory we're going to look under?
$rootPath = (Get-Location)

foreach($childItem in (Get-ChildItem $rootPath -Recurse))
{
	# if it's a folder AND does not have child items of its own
	if( ($childItem.PSIsContainer) -and (!(Get-ChildItem -Recurse -Path $childItem.FullName)))
	{
		# Delete it
		Remove-Item $childItem.FullName -Confirm:$false
	}
}