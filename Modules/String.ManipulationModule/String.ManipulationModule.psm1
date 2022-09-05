# InsertOrUpdate-ValueInString.ps1



# From repository: https://github.com/ElianFabian/powershell-utils



<#
    .SYNOPSIS
    Inserts or updates a value. To update the value it needs the value's regex value's key to identify it.
#>
function AddOrUpdate-ValueInString
(
    [string]      $ValueToAddOrUpdate,
    [string]      $ValueRegex,
    [string]      $ValueKey,
    [string]      $SourceString,
    [Scriptblock] $AddValue = {
        param($sourceString, $valueToAdd)

        return $sourceString + $valueToAdd
    },
    [scriptblock] $UpdateValue = {
        param($updatedText)

        return $updatedText
    }
) {
    $textMatches = ($SourceString | Select-String -Pattern $ValueRegex -AllMatches).Matches

    if ($null -eq $textMatches) # Add
    {
        return $AddValue.Invoke($SourceString, $ValueToAddOrUpdate)
    }
    else # Update
    {
        foreach ($match in $textMatches)
        {
            if (-not $match.Value.Contains($ValueKey)) { continue }

            return $SourceString -replace $match.Value, $UpdateValue.Invoke($ValueToAddOrUpdate)
        }
    }
}
