# PascalCase


function ConvertFrom-PascalCase([string] $InputObject)
{
    return [regex]::Replace($InputObject, '(?<=.)(?=[A-Z])', $BaseCaseSeparator).ToLower()
}

function ConvertTo-PascalCase([string] $InputObject)
{
    return [regex]::Replace( $InputObject, "(^|$BaseCaseSeparator)(.)", { $args[0].Groups[2].Value.ToUpper() } )
}
