# files_deleteSquareBracketsInFileName.ps1

# Deletes all the square brackets from all the file names

# This is suppose to use when renaming several folders at one with square brackets (which can give you erros)

(Get-ChildItem -File -Recurse) | Rename-Item -NewName { $_.Name -replace "[\[\]]" }
