# StringModule.psm1



# From repository: https://github.com/ElianFabian/powershell-utils



function Set-Case([string] $InputObject, [CaseType] $From, [CaseType] $To)
{
    $caseCombination = "$From-$To"

    switch ($caseCombination)
    {
        "CamelCase-PascalCase"     { From-CamelCase-To-PascalCase             $InputObject }
        "CamelCase-SnakeCase"      { From-CamelOrPascalCase-To-SnakeCase      $InputObject }
        "CamelCase-UpperSnakeCase" { From-CamelOrPascalCase-To-UpperSnakeCase $InputObject }
        "CamelCase-KebabCase"      { From-CamelOrPascalCase-To-KebabCase      $InputObject }
        "CamelCase-TrainCase"      { From-CamelOrPascalCase-To-TrainCase      $InputObject }

        "PascalCase-CamelCase"      { From-PascalCase-To-CamelCase             $InputObject }
        "PascalCase-SnakeCase"      { From-CamelOrPascalCase-To-SnakeCase      $InputObject }
        "PascalCase-UpperSnakeCase" { From-CamelOrPascalCase-To-UpperSnakeCase $InputObject }
        "PascalCase-KebabCase"      { From-CamelOrPascalCase-To-KebabCase      $InputObject }
        "PascalCase-TrainCase"      { From-CamelOrPascalCase-To-TrainCase      $InputObject }

        "SnakeCase-CamelCase"      { From-SnakeCase-To-CamelCase  $InputObject }
        "SnakeCase-PascalCase"     { From-SnakeCase-To-PascalCase $InputObject }
        "SnakeCase-UpperSnakeCase" {                              $InputObject.ToUpper() }
        "SnakeCase-KebabCase"      {                              $InputObject.Replace("_", "-") }
        "SnakeCase-TrainCase"      { From-SnakeCase-To-TrainCase  $InputObject }

        "UpperSnakeCase-CamelCase"  { From-SnakeCase-To-CamelCase  $InputObject.ToLower() }
        "UpperSnakeCase-PascalCase" { From-SnakeCase-To-PascalCase $InputObject.ToLower() }
        "UpperSnakeCase-SnakeCase"  {                              $InputObject.ToLower() }
        "UpperSnakeCase-KebabCase"  {                              $InputObject.ToLower().Replace("_", "-") }
        "UpperSnakeCase-TrainCase"  { From-SnakeCase-To-TrainCase  $InputObject.ToLower() }

        "KebabCase-CamelCase"      { From-SnakeCase-To-CamelCase  $InputObject.Replace("-", "_") }
        "KebabCase-PascalCase"     { From-SnakeCase-To-PascalCase $InputObject.Replace("-", "_") }
        "KebabCase-SnakeCase"      {                              $InputObject.Replace("-", "_") }
        "KebabCase-UpperSnakeCase" {                              $InputObject.Replace("-", "_").ToUpper() }
        "KebabCase-TrainCase"      { From-SnakeCase-To-TrainCase  $InputObject.Replace("-", "_") }

        "TrainCase-CamelCase"      { From-PascalCase-To-CamelCase $InputObject.Replace("-", "") }
        "TrainCase-PascalCase"     {                              $InputObject.Replace("-", "") }
        "TrainCase-SnakeCase"      {                              $InputObject.Replace("-", "_").ToLower() }
        "TrainCase-UpperSnakeCase" {                              $InputObject.Replace("-", "_").ToUpper() }
        "TrainCase-KebabCase"      {                              $InputObject.ToLower() }

        default { throw "Invalid case combination: $caseCombination" }
    }
}


#region Generic

function From-CamelOrPascalCase-To-SnakeCase([string] $InputObject)
{
    return [regex]::replace($InputObject, '(?<=.)(?=[A-Z])', '_').ToLower()
}

function From-CamelOrPascalCase-To-UpperSnakeCase([string] $InputObject)
{
    return [regex]::replace($InputObject, '(?<=.)(?=[A-Z])', '_').ToUpper()
}

function From-CamelOrPascalCase-To-KebabCase([string] $InputObject)
{
    return [regex]::replace($InputObject, '(?<=.)(?=[A-Z])', '-').ToLower()
}

function From-CamelOrPascalCase-To-TrainCase([string] $InputObject)
{
    $toPascalCase = From-CamelCase-To-PascalCase $InputObject

    return [regex]::replace($toPascalCase, '(?<=.)(?=[A-Z])', '-')
}

#endregion

#region CamelCase

function From-CamelCase-To-PascalCase([string] $InputObject)
{
    $firstChar = $InputObject[0]

    $firstCharToUpper = [char]::ToUpper($firstChar)

    return $InputObject.Remove(0, 1).Insert(0, $firstCharToUpper)
}

#endregion

#region PascalCase

function From-PascalCase-To-CamelCase([string] $InputObject)
{
    $firstChar = $InputObject[0]

    $firstCharToLower = [char]::ToLower($firstChar)

    return $InputObject.Remove(0, 1).Insert(0, $firstCharToLower)
}

#endregion

#region SnakeCase

function From-SnakeCase-To-CamelCase([string] $InputObject)
{
    $pascalCaseValue = [regex]::replace($InputObject.ToLower(), '(^|_)(.)', { $args[0].Groups[2].Value.ToUpper()})

    $camelCaseValue = From-PascalCase-To-CamelCase $pascalCaseValue

    return $camelCaseValue
}

function From-SnakeCase-To-PascalCase([string] $InputObject)
{
    return [regex]::replace($InputObject.ToLower(), '(^|_)(.)', { $args[0].Groups[2].Value.ToUpper()})
}

function From-SnakeCase-To-TrainCase([string] $InputObject)
{
    $toCamelCase = From-SnakeCase-To-CamelCase $InputObject

    $toTrainCase = From-CamelOrPascalCase-To-TrainCase $toCamelCase

    return $toTrainCase
}

#endregion



Export-ModuleMember -Function `
    Set-Case
