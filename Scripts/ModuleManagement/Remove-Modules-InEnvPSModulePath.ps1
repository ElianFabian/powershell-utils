# Remove-Modules-InEnvPSModulePath.ps1



# From repository: https://github.com/ElianFabian/powershell-utils



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
