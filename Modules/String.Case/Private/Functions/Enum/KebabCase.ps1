# kebab-case


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
