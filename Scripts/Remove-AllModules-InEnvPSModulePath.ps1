# Remove-AllModules-InEnvPSModulePath.ps1



# From repository: https://github.com/ElianFabian/powershell-utils



$userModulePath = $env:PSModulePath.Split(";")[0]

Get-ChildItem -Path $userModulePath -Exclude PackageManagement | Remove-Item -Recurse -Force -Confirm:$false
