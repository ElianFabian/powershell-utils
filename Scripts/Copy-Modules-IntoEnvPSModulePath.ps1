# Copy-Modules-IntoEnvPSModulePath.ps1

$userModulePath = $env:PSModulePath.Split(";")[0]

Copy-Item -Path ..\Modules\* -Destination $userModulePath -Recurse


Invoke-Item -Path $userModulePath