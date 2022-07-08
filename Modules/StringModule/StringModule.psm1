# StringModule.psm1



# From repository: https://github.com/ElianFabian/powershell-utils



# We have a base case from which we're going to convert from and convert to.
# Base case: something&and&something&else

#region Case Functions

function ConvertTo-CamelCase
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string] $InputObject
    )

    end { [regex]::replace($InputObject.ToLower(), '(&)(.)', { $args[0].Groups[2].Value.ToUpper()}) }
}

filter ConvertFrom-CamelCase
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string] $InputObject
    )

    end { [regex]::replace($InputObject, '(?<=.)(?=[A-Z])', '&').ToLower() }
}

function ConvertTo-PascalCase
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string] $InputObject
    )

    end { [regex]::replace( $InputObject.ToLower(), '(^|&)(.)', { $args[0].Groups[2].Value.ToUpper() } ) }
}

filter ConvertFrom-PascalCase
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string] $InputObject
    )

    end { $InputObject | ConvertFrom-CamelCase }
}

function ConvertTo-SnakeCase
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string] $InputObject
    )

    end { $InputObject.Replace("&", "_") }
}

filter ConvertFrom-SnakeCase
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string] $InputObject
    )

    end { $InputObject.Replace("_", "&") }
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

filter ConvertFrom-UpperSnakeCase
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string] $InputObject
    )

    end { $InputObject.ToLower() | ConvertFrom-SnakeCase }
}

function ConvertTo-KebabCase
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string] $InputObject
    )

    end { $InputObject.Replace("&", "-") }
}

filter ConvertFrom-KebabCase
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string] $InputObject
    )

    end { $InputObject.Replace("-", "&") }
}

function ConvertTo-TrainCase
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string] $InputObject
    )

    end { [regex]::replace( $InputObject.ToLower(), '(^|&)(.)', { "-" + $args[0].Groups[2].Value.ToUpper()} ).Remove(0, 1) }
}

filter ConvertFrom-TrainCase
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string] $InputObject
    )

    end { $InputObject.Replace("-", "").ToLower() }
}

#endregion

$convertTo = @{
    CamelCase      = 'ConvertTo-CamelCase';
    PascalCase     = 'ConvertTo-PascalCase';
    SnakeCase      = 'ConvertTo-SnakeCase';
    UpperSnakeCase = 'ConvertTo-UpperSnakeCase';
    KebabCase      = 'ConvertTo-KebabCase';
    TrainCase      = 'ConvertTo-TrainCase';
}

$convertFrom = @{
    CamelCase      = 'ConvertFrom-CamelCase';
    PascalCase     = 'ConvertFrom-PascalCase';
    SnakeCase      = 'ConvertFrom-SnakeCase';
    UpperSnakeCase = 'ConvertFrom-UpperSnakeCase';
    KebabCase      = 'ConvertFrom-KebabCase';
    TrainCase      = 'ConvertFrom-TrainCase';
}

function Set-Case([string] $InputObject, [CaseType] $From, [CaseType] $To)
{
    Invoke-Expression "'$InputObject' | & $($convertFrom[$From.ToString()]) | & $($convertTo[$To.ToString()])"
}



Export-ModuleMember -Function `
    Set-Case
