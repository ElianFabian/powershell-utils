# system_switch_dark-light_mode.ps1

# Changes the system theme between dark and light mode

$AppsUseLightTheme = "AppsUseLightTheme"

$isUsingLightTheme = (Get-Item HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize).GetValue($AppsUseLightTheme)

if ($isUsingLightTheme)
{
    Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name $AppsUseLightTheme -Value 0
}
else
{
    Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name $AppsUseLightTheme -Value 1
}
