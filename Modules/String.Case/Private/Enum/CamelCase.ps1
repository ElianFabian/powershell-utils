# camelCase


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
