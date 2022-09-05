# snake_case


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
