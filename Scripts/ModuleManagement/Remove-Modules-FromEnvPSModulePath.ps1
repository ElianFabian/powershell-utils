# Remove-Modules-FromEnvPSModulePath.ps1



$userModulePath = $env:PSModulePath.Split(";")[0]

$modulesFromRepository   = (Get-ChildItem -Path ..\..\Modules\*).Name
$modulesFromUserComputer = (Get-ChildItem -Path $userModulePath)

foreach ($modulePath in $modulesFromUserComputer)
{
    if ($modulesFromRepository -contains $modulePath.Name)
    {
        Remove-Item -Path $modulePath.FullName -Force -Recurse -Confirm:$false
    }
}

Remove-Item -Path $userModulePath/AutogeneratedModules -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "../../Modules/AutogeneratedModules" -Recurse -Force -ErrorAction SilentlyContinue
