#region Enums
enum LanguageType
{
    CSharp;
    Java;
    Kotlin;
}
#endregion
# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
