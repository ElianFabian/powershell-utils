# InsertOrUpdate-ValueInString.ps1



# From repository: https://github.com/ElianFabian/powershell-utils


<#
    .SYNOPSIS
    Inserts or updates a value. To update the value it needs the value's regex value's key to identify it.
#>
param(
    [string]      $ValueToInsertOrUpdate,
    [string]      $ValueRegex,
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



$textMatches = ($SourceString | Select-String -Pattern $ValueRegex -AllMatches).Matches

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
