# Translation.psm1



$global:languagesCsv = ConvertFrom-Csv -InputObject ( Get-Content "$PSScriptRoot/Languages.csv" -Raw )

$languagesToCodes = @{}
foreach($row in $global:languagesCsv)
{
    $languagesToCodes.$($row.Language) = $row.Code
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
    Text to translate

    .PARAMETER $SourceLanguage
    Source language in English or language code.

    .PARAMETER $TargetLanguage
    Target language in English or language code.
#>
function Convert-Language(
    [string] $InputObject,
    [ValidateSet([Language])]
    [string] $SourceLanguage = 'auto',
    [ValidateSet([Language])]
    [string] $TargetLanguage
) {
    if ($languagesToCodes.ContainsKey(($SourceLanguage)))
    {
        $sourceLanguageCode = $languagesToCodes[$SourceLanguage]
    }
    else { $sourceLanguageCode = $SourceLanguage }

    if ($languagesToCodes.ContainsKey(($TargetLanguage)))
    {
        $targetLanguageCode = $languagesToCodes[$TargetLanguage]
    }
    else { $targetLanguageCode = $TargetLanguage }


    $translationSB = [System.Text.StringBuilder]::new()

    $uri = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=$sourceLanguageCode&tl=$targetLanguageCode&dt=t&q=$([uri]::EscapeDataString($InputObject))"

    $response = (Invoke-WebRequest -Uri $uri -Method Get).Content | ConvertFrom-Json

    foreach ($translatedLine in $response[0])
    {
        $translationSB.Append($translatedLine[0]) > $null
    }

    return $translationSB.ToString()
}



Export-ModuleMember -Function Convert-Language