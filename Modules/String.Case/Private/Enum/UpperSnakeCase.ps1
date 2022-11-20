# UPPER_SNAKE_CASE


. "./SnakeCase.ps1"

function ConvertFrom-UpperSnakeCase([string] $InputObject)
{
    return ConvertFrom-SnakeCase $InputObject.ToLower()
}

function ConvertTo-UpperSnakeCase([string] $InputObject)
{
    return (ConvertTo-SnakeCase $InputObject).ToUpper()
}
