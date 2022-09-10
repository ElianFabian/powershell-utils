# Setup.ps1



& ./Autogenerate-Modules.ps1
& ./Import-Modules-IntoEnvPSModulePath.ps1
& ./Import-UsingStatements-IntoProfile.ps1
