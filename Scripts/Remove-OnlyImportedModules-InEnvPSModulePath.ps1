# Remove-OnlyImportedModules-InEnvPSModulePath.ps1



$userModulePath = $env:PSModulePath.Split(";")[0]

$modulesFromRepository = (Get-ChildItem -Path ..\Modules\*).Name

$modulesFromUserComputer = (Get-ChildItem -Path $userModulePath)

$modulesFromUserComputer | ForEach-Object {

    if ($modulesFromRepository.Contains($_.Name))
    {
        Remove-Item -Path $_.FullName -Force -Recurse -Confirm:$false
    }
}
