# Remove-UsingStatements-FromProfile.ps1



# From repository: https://github.com/ElianFabian/powershell-utils



Import-Module -Name "../../Modules/String.ManipulationModule/String.ManipulationModule.psm1" -WarningAction SilentlyContinue



$REGEX_AUTOGENERATED_TEXT = "#<([\S\s]*?)>#"
$GITHUB_REPOSITORY        = "https://github.com/ElianFabian/powershell-utils"


$newValue = AddOrUpdate-ValueInString `
    -ValueRegex   $REGEX_AUTOGENERATED_TEXT `
    -ValueKey     $GITHUB_REPOSITORY `
    -SourceString (Get-Content -Path $PROFILE -Raw) `
    -UpdateValue  { return '' }

Set-Content -Path $PROFILE -Value $newValue -NoNewline
