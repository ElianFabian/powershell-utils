# String.Case.psm1



# From repository: https://github.com/ElianFabian/powershell-utils



# We have a base case from which we're going to convert from and convert to.
# Base case: something&and&something&else


$BaseCaseSeparator = "&"


enum CaseType
{
	CamelCase      # camelCase
	PascalCase     # PascalCase
	SnakeCase      # snake_case
	UpperSnakeCase # SNAKE_CASE
	KebabCase      # kebab-case
	TrainCase      # Train-Case
}


#region Case Functions

function ConvertFrom-CamelCase([string] $InputObject)
{
    return [regex]::Replace($InputObject, '(?<=.)(?=[A-Z])', $BaseCaseSeparator).ToLower()
}

function ConvertTo-CamelCase([string] $InputObject)
{
    $text = [regex]::replace($InputObject, "($BaseCaseSeparator)(.)", { $args[0].Groups[2].Value.ToUpper() })

    $firstChar = $text[0].ToString().ToLower()

    return $text.Remove(0, 1).Insert(0, $firstChar)
}

function ConvertFrom-PascalCase([string] $InputObject)
{
    return ConvertFrom-CamelCase $InputObject
}

function ConvertTo-PascalCase([string] $InputObject)
{
    return [regex]::Replace( $InputObject, "(^|$BaseCaseSeparator)(.)", { $args[0].Groups[2].Value.ToUpper() } )
}

function ConvertFrom-SnakeCase([string] $InputObject)
{
    return $InputObject.Replace("_", $BaseCaseSeparator)
}

function ConvertTo-SnakeCase([string] $InputObject)
{
    $text = [regex]::Replace( $InputObject, "(^|$BaseCaseSeparator)(.)", { "_$($args[0].Groups[2].Value.ToLower())" } ).Remove(0, 1)

    $firstChar = $text[0].ToString().ToLower()

    return $text -replace "^.", $firstChar
}

function ConvertFrom-UpperSnakeCase([string] $InputObject)
{
    return $InputObject.ToLower() | ConvertFrom-SnakeCase
}

function ConvertTo-UpperSnakeCase([string] $InputObject)
{
    return $InputObject.ToUpper() | ConvertTo-SnakeCase
}

function ConvertFrom-KebabCase([string] $InputObject)
{
    return $InputObject.Replace("-", $BaseCaseSeparator)
}

function ConvertTo-KebabCase([string] $InputObject)
{
    $text = $InputObject.Replace($BaseCaseSeparator, "-")

    $firstChar = $text[0].ToString().ToLower()

    return $text.Remove(0, 1).Insert(0, $firstChar)
}

function ConvertFrom-TrainCase([string] $InputObject)
{
    return $InputObject.Replace("-", $BaseCaseSeparator)
}


function ConvertTo-TrainCase([string] $InputObject)
{
    return [regex]::Replace( $InputObject, "(^|$BaseCaseSeparator)(.)", { "-$($args[0].Groups[2].Value.ToUpper())" } ).Remove(0, 1)
}

#endregion

$caseTypeNames = [CaseType].GetEnumNames()

$fromFunctions = New-Object System.Collections.Generic.Dictionary'[string, string]'
$toFunctions   = New-Object System.Collections.Generic.Dictionary'[string, string]'

foreach ($caseType in $caseTypeNames)
{
    $fromFunctions.Add($caseType, "ConvertFrom-$caseType")
    $toFunctions.Add($caseType, "ConvertTo-$caseType")
}



function Convert-Case
{
    param(
        [Parameter(ValueFromPipeline)]
        [string] $InputObject,
        [CaseType] $From, [CaseType] $To
    )

    process { & $toFunctions[$To.ToString()] (& $fromFunctions[$From.ToString()] $InputObject) }
}


Export-ModuleMember -Function Convert-Case
