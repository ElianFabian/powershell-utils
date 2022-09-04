# AddOrUpdate-ValueInString.ps1



# From repository: https://github.com/ElianFabian/powershell-utils



param(
    [string] $TextToAddOrUpdate,
    [string] $TextRegex,
    [string] $TextKey,
    [string] $SourceValue,
    [Scriptblock] $GetNewValue = {
        param($sourceValue, $textToAdd)

        return $sourceValue + $textToAdd
    },
    [scriptblock] $UpdateValue = {
        param($updatedText)

        return $updatedText
    }
)



$textMatches = ($SourceValue | Select-String -Pattern $TextRegex -AllMatches).Matches

#region Add
if ($null -eq $textMatches)
{
    return $GetNewValue.Invoke($SourceValue, $TextToAddOrUpdate)
}
#endregion
#region Update
else
{
    foreach ($match in $textMatches)
    {
        if (-not $match.Value.Contains($TextKey)) { continue }

        return $SourceValue -replace $match.Value, $UpdateValue.Invoke($TextToAddOrUpdate)
    }
}
#endregion
