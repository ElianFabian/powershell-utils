# add_prefix_to_file_name.ps1

# Adds a prefix to all the file names from current directory

echo ''

if ($args) 
{
	$prefix = $args[0]
}
else
{
	$prefix = Read-Host 'Introduce the prefix you want to add'
}

(Get-ChildItem -File) | Rename-Item -NewName { "$prefix $_" }

echo ''
