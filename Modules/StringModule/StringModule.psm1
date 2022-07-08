# StringModule.psm1



# From repository: https://github.com/ElianFabian/powershell-utils



# We have a base case from which we're going to convert from and convert to.
# Base case: something&and&something&else

#region Case Functions

$BaseCaseSeparator = "&"


function ConvertFrom-CamelCase
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string] $InputObject
    )

    end { [regex]::replace($InputObject, '(?<=.)(?=[A-Z])', $BaseCaseSeparator).ToLower() }
}

function ConvertTo-CamelCase
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string] $InputObject
    )

    end { [regex]::replace($InputObject.ToLower(), "($BaseCaseSeparator)(.)", { $args[0].Groups[2].Value.ToUpper()}) }
}

function ConvertFrom-PascalCase
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string] $InputObject
    )

    end { $InputObject | ConvertFrom-CamelCase }
}

function ConvertTo-PascalCase
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string] $InputObject
    )

    end { [regex]::replace( $InputObject.ToLower(), "(^|$BaseCaseSeparator)(.)", { $args[0].Groups[2].Value.ToUpper() } ) }
}

function ConvertFrom-SnakeCase
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string] $InputObject
    )

    end { $InputObject.Replace("_", $BaseCaseSeparator) }
}

function ConvertTo-SnakeCase
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string] $InputObject
    )

    end { $InputObject.Replace($BaseCaseSeparator, "_") }
}

function ConvertFrom-UpperSnakeCase
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string] $InputObject
    )

    end { $InputObject.ToLower() | ConvertFrom-SnakeCase }
}

function ConvertTo-UpperSnakeCase
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string] $InputObject
    )

    end { $InputObject.ToUpper() | ConvertTo-SnakeCase }
}

function ConvertFrom-KebabCase
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string] $InputObject
    )

    end { $InputObject.Replace("-", $BaseCaseSeparator) }
}

function ConvertTo-KebabCase
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string] $InputObject
    )

    end { $InputObject.Replace($BaseCaseSeparator, "-") }
}

function ConvertFrom-TrainCase
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string] $InputObject
    )

    end { $InputObject.Replace("-", $BaseCaseSeparator).ToLower() }
}

function ConvertTo-TrainCase
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string] $InputObject
    )

    end { [regex]::replace( $InputObject.ToLower(), "(^|$BaseCaseSeparator)(.)", { "-" + $args[0].Groups[2].Value.ToUpper()} ).Remove(0, 1) }
}

#endregion



function Set-Case([string] $InputObject, [CaseType] $From, [CaseType] $To)
{
    Invoke-Expression "'$InputObject' | ConvertFrom-$From | ConvertTo-$To"
}



Export-ModuleMember -Function `
    Set-Case
