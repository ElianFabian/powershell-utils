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

$textToAdd = "`n`n$SEPARATOR`n"
$textToAdd += "`# Modules added using Append-UsingModuleStatements-IntoProfile.ps1`n`n$usingModuleStatments"
$textToAdd += "`n# ====================================================================================`n`n"

Add-Content -Path $PROFILE -Value $textToAdd

Start-Process notepad $PROFILE
