# Autogenerates the CaseType enum
# This script must be execute from another general autogenerator script

$tabSize = 4
$tab     = " " * $tabSize

$caseEnum = "enum CaseType`n{`n"

$caseTypes = (Get-ChildItem -Path $PSScriptRoot/Private/Functions/Enum/ -File).BaseName

$separator = ''

foreach ($caseType in $caseTypes)
{
    $caseEnum += "$separator$tab$caseType"

    $separator = "`n"
}

$caseEnum += "`n}`n"

return $caseEnum