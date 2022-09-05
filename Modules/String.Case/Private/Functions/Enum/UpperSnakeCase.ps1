# UPPER_SNAKE_CASE


. "./SnakeCase.ps1"

function ConvertFrom-UpperSnakeCase([string] $InputObject)
{
    return $InputObject.ToLower() | ConvertFrom-SnakeCase
}

function ConvertTo-UpperSnakeCase([string] $InputObject)
{
    return $InputObject.ToUpper() | ConvertTo-SnakeCase
}
