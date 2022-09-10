# Train-Case


function ConvertFrom-TrainCase([string] $InputObject)
{
    return $InputObject.Replace("-", $BaseCaseSeparator)
}

function ConvertTo-TrainCase([string] $InputObject)
{
    return [regex]::Replace( $InputObject, "(^|$BaseCaseSeparator)(.)", { "-$($args[0].Groups[2].Value.ToUpper())" } ).Remove(0, 1)
}
