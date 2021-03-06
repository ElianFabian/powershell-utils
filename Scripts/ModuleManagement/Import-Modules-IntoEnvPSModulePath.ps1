# Import-Modules-IntoEnvPSModulePath.ps1



# From repository: https://github.com/ElianFabian/powershell-utils



$userModulePath = $env:PSModulePath.Split(";")[0]

# In case the folder doesn't exist, create it (This is for Porweshell 7 support)
New-Item $userModulePath -ItemType Directory -ErrorAction SilentlyContinue

Copy-Item -Path ..\..\Modules\* -Destination $userModulePath -Recurse


# Invoke-Item -Path $userModulePath
