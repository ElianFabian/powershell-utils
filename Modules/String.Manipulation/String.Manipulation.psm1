# String.Manipulation.psm1



<#
    .SYNOPSIS
    Inserts or updates a value. To update the value it needs the value's regex value's key to identify it.
#>
function InsertOrUpdate-ValueInString
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
) {
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
    Given a string gets every item using a pattern to convert it into another string with items.  
    .PARAMETER InputObject
    A string of items that matches a certain pattern.  
    .PARAMETER ItemPattern
    The pattern to match each item of the given InputObject.  
    .PARAMETER ItemSeparator
    It's the string that separates each item, by default it's a new line.  
    .PARAMETER OnCreateItem
    An script block which $args contains all the groups defined in $ItemPattern and returns an item as string.  
    .EXAMPLE
    Convert-ItemToItemWithRegex `
        -InputObject @"
        <string name="name">Alice</string>
        <string name="age">25</string>
        "@ `
        -ItemPattern '<string name="(.+)">(.+)<\/string>' `
        -OnCreateItem { $name, $content = $args  
            "$name = ""$content"""
        }
    output:
        name = "Alice"
        age = 25
#>
function Convert-ItemToItemWithRegex
(
    [string]      $InputObject,
    [string]      $ItemPattern,
    [string]      $ItemSeparator = "`n",
    [scriptblock] $OnCreateItem
) {
    $resultSB = [System.Text.StringBuilder]::new()

    $currentIndex = 0
    $separator    = ''

    $allMatches = $InputObject | Select-String -Pattern $ItemPattern -AllMatches | Select-Object -ExpandProperty Matches

    foreach ($match in $allMatches)
    {
        $_first, $groups = $match.Groups | Select-Object -ExpandProperty Value

        $newItem = & $OnCreateItem @groups

        $resultSB.Append("$separator$newItem") > $null

        $currentIndex++
        $separator = $ItemSeparator
    }

    return $resultSB.ToString()
}