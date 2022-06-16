# Append-UsingModuleStatements-IntoProfile.ps1



# In this file we have to add the modules that contains classes or enums because they need to be imported with the "using module" statement.



$modules = @(
    "EnumModule"
)

$usingModuleStatments = ""

foreach ($module in $modules)
{
    $usingModuleStatments += "using module $module`n"
}


$SEPARATOR = "# ===================================================================================="

$textToAdd = "`n`n# Modules added using Append-UsingModuleStatements-IntoProfile.ps1"
$textToAdd += "`n$SEPARATOR`n`n"
$textToAdd += $usingModuleStatments
$textToAdd += "`n$SEPARATOR`n"

Add-Content -Path $PROFILE -Value $textToAdd

Start-Process notepad $PROFILE
