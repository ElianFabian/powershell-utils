# _how_to.ps1


exit # This is to avoid someone executing this file


# Read properties file
$properties = Get-Content .\file.txt | ConvertFrom-StringData