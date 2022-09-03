# Setup.ps1



# From repository: https://github.com/ElianFabian/powershell-utils


& .\Autogenerate-Modules.ps1
& .\Import-Modules-IntoEnvPSModulePath.ps1
& .\Update-UsingModuleStatements-InProfile.ps1
