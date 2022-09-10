# Import-Modules-IntoEnvPSModulePath.ps1



$userModulePath = $env:PSModulePath.Split(";")[0]

# In case the folder doesn't exist, create it (This is for Porweshell 7 support)
New-Item $userModulePath -ItemType Directory -ErrorAction SilentlyContinue

Copy-Item -Path ..\..\Modules\* -Destination $userModulePath -Recurse -Force


# Invoke-Item -Path $userModulePath
