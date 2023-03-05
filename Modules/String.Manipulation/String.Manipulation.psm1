# String.Manipulation.psm1



<#
    .SYNOPSIS
    Inserts or updates a value. To update the value it needs the value's regex value's key to identify it.
#>
function InsertOrUpdate-ValueInString
{
    param
    (
        [string]      $ValueToInsertOrUpdate,
        [string]      $ValuePattern,
        [string]      $ValueKey,
        [string]      $SourceString,
        [Scriptblock] $InsertValue = {
            param($sourceString, $valueToInsert)

            return $sourceString + $valueToInsert
        },
        [scriptblock] $UpdateValue = {
            param($updatedText)

            return $updatedText
        }
    )

    $textMatches = ($SourceString | Select-String -Pattern $ValuePattern -AllMatches).Matches

    if ($null -eq $textMatches) # Insert
    {
        return $InsertValue.Invoke($SourceString, $ValueToInsertOrUpdate)
    }
    else # Update
    {
        foreach ($match in $textMatches)
        {
            if (-not $match.Value.Contains($ValueKey)) { continue }

            return $SourceString -replace $match.Value, $UpdateValue.Invoke($ValueToInsertOrUpdate)
        }
    }
}

<#
    .SYNOPSIS
    Given a string returns an array of every item using a pattern to convert it into another string with items.
    .PARAMETER InputObject
    A string of items that matches a certain pattern.
    .PARAMETER ItemPattern
    The pattern to match each item of the given InputObject. 
    .PARAMETER OnGetItem
    An script block which $args contains all the groups defined in $ItemPattern and returns an item as string.
    .EXAMPLE
    Convert-ItemWithRegex `
        -InputObject @"
        <string name="name">Alice</string>
        <string name="age">25</string>
    "@ `
        -ItemPattern '<string name="(.+)">(.+)<\/string>' `
        -OnGetItem { $name, $content = $args  
            "$name = ""$content"""
        }
    output:
        name = "Alice"
        age = "25"
#>
function Convert-ItemWithRegex
{
    [OutputType([object[]])]
    param
    (
        [Parameter(Mandatory=$true)]
        [string] $InputObject,
        [Parameter(Mandatory=$true)]
        [string] $ItemPattern,
        [Parameter(Mandatory=$true)]
        [scriptblock] $OnGetItem
    )

    $allMatches = $InputObject | Select-String -Pattern $ItemPattern -AllMatches | Select-Object -ExpandProperty Matches

    $arrayOfItems = New-Object object[] $allMatches.Count

    $itemIndex = 0
    foreach ($match in $allMatches)
    {
        $_first, $groups = foreach ($group in $match.Groups) { $group.Value }

        $newItem = $OnGetItem.Invoke($groups)

        $arrayOfItems[$itemIndex] = $newItem

        $itemIndex++
    }

    return $arrayOfItems
}




Export-ModuleMember -Function *-*
