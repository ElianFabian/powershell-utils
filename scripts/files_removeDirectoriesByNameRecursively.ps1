# files_removeDirectoriesByNameRecursively.ps1

# https://stackoverflow.com/questions/3648142/how-can-i-recursively-delete-folder-with-a-specific-name-with-powershell

Get-Childitem -Include "build" -Recurse -force | Remove-Item -Force -Recurse