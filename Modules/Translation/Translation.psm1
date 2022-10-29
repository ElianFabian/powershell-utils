# Translation.psm1



$global:languagesCsv = ConvertFrom-Csv -InputObject ( Get-Content "$PSScriptRoot/Languages.csv" -Raw )

$languagesToCodes = @{}
foreach($row in $global:languagesCsv)
{
    $languagesToCodes[$row.Language] = $row.Code
}

class Language : System.Management.Automation.IValidateSetValuesGenerator
{
    [String[]] GetValidValues()
    {

        $languages = $global:languagesCsv | ForEach-Object { $_.Language }
        $codes     = $global:languagesCsv | ForEach-Object { $_.Code }

        return $languages + $codes
    }
}



<#
    .DESCRIPTION
    Translated the given input from a language to another language.

    .PARAMETER InputObject
    Text to translate.

    .PARAMETER $SourceLanguage
    Source language in English or language code.

    .PARAMETER $TargetLanguage
    Target language in English or language code.

    .NOTES
    This function uses the free google translate api, if you try to do so many calls it will block (you will probably only find issues when doing parallelism).
#>
function Invoke-LanguageTranslation(
    [string] $InputObject,
    [ValidateSet([Language])]
    [string] $SourceLanguage = 'auto',
    [ValidateSet([Language])]
    [string] $TargetLanguage
) {
    $sourceLanguageCode, $targetLanguageCode = TryConvertLanguageToCode $SourceLanguage $TargetLanguage

    $translationSB = [System.Text.StringBuilder]::new()

    $query = [uri]::EscapeDataString($InputObject)

    $uri = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=$sourceLanguageCode&tl=$targetLanguageCode&dt=t&q=$query"

    $response = (Invoke-WebRequest -Uri $uri -Method Get).Content | ConvertFrom-Json

    foreach ($translatedLine in $response[0])
    {
        $translationSB.Append($translatedLine[0]) > $null
    }

    return $translationSB.ToString()
}

function TryConvertLanguageToCode([string] $SourceLanguage, [string] $TargetLanguage)
{
    $languageCodes = @($SourceLanguage, $TargetLanguage)

    if ($languagesToCodes.ContainsKey(($SourceLanguage)))
    {
        $languageCodes[0] = $languagesToCodes[$SourceLanguage]
    }
    if ($languagesToCodes.ContainsKey(($TargetLanguage)))
    {
        $languageCodes[1] = $languagesToCodes[$TargetLanguage]
    }

    return $languageCodes
}



Export-ModuleMember -Function *-*