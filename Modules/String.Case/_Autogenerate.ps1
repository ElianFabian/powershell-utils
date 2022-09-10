# Autogenerates the CaseType enum



$tabSize = 4
$tab     = " " * $tabSize

$caseEnum = "enum CaseType`n{`n"

$caseTypes = (Get-ChildItem -Path $PSScriptRoot/Private/Enum/ -File).BaseName

$separator = ''

foreach ($caseType in $caseTypes)
{
    $caseEnum += "$separator$tab$caseType"

    $separator = "`n"
}

$caseEnum += "`n}`n"

return $caseEnum
