# Remove-Modules-InEnvPSModulePath.ps1



$userModulePath = $env:PSModulePath.Split(";")[0]

Get-ChildItem -Path $userModulePath -Exclude PackageManagement | Remove-Item -Recurse -Force -Confirm:$false
