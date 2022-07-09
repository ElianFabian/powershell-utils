# Remove-OnlyImportedModules-InEnvPSModulePath.ps1



# From repository: https://github.com/ElianFabian/powershell-utils



$userModulePath = $env:PSModulePath.Split(";")[0]

$modulesFromRepository = (Get-ChildItem -Path ..\..\Modules\*).Name

$modulesFromUserComputer = (Get-ChildItem -Path $userModulePath)

$modulesFromUserComputer | ForEach-Object {

    if ($modulesFromRepository.Contains($_.Name))
    {
        Remove-Item -Path $_.FullName -Force -Recurse -Confirm:$false
    }
}
