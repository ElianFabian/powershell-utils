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

    end
    {
        $text = [regex]::replace($InputObject, "($BaseCaseSeparator)(.)", { $args[0].Groups[2].Value.ToUpper()})

        $firstChar = $text[0].ToString().ToLower()

        return $text.Remove(0, 1).Insert(0, $firstChar)
    }
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

    end { [regex]::replace( $InputObject, "(^|$BaseCaseSeparator)(.)", { $args[0].Groups[2].Value.ToUpper() } ) }
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

    end
    {
        $text = $InputObject.Replace($BaseCaseSeparator, "_")

        $firstChar = $text[0].ToString().ToLower()

        return $text.Remove(0, 1).Insert(0, $firstChar)
    }
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

    end
    {
        $text = $InputObject.Replace($BaseCaseSeparator, "-")

        $firstChar = $text[0].ToString().ToLower()

        return $text.Remove(0, 1).Insert(0, $firstChar)
    }
}

function ConvertFrom-TrainCase
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string] $InputObject
    )

    end { $InputObject.Replace("-", $BaseCaseSeparator) }
}

function ConvertTo-TrainCase
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string] $InputObject
    )

    end { [regex]::replace( $InputObject, "(^|$BaseCaseSeparator)(.)", { "-$($args[0].Groups[2].Value.ToUpper())" } ).Remove(0, 1) }
}

#endregion



function Set-Case
{
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string] $InputObject,
        [CaseType] $From, [CaseType] $To
    )

    process { Invoke-Expression "'$InputObject' | ConvertFrom-$From | ConvertTo-$To" }
}



Export-ModuleMember -Function `
    Set-Case
