# Copy-Modules-IntoEnvPSModulePath.ps1



# From repository: https://github.com/ElianFabian/powershell-utils



$userModulePath = $env:PSModulePath.Split(";")[0]

Copy-Item -Path ..\Modules\* -Destination $userModulePath -Recurse


Invoke-Item -Path $userModulePath
