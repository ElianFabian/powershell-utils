# Append-UsingModuleStatements-IntoProfile.ps1



# From repository: https://github.com/ElianFabian/powershell-utils



# In this file we have to add the modules that contains classes or enums because they need to be imported with the "using module" statement.



$modules = @(
    "EnumModule"
)

$usingModuleStatments = ""

foreach ($module in $modules)
{
    $usingModuleStatments += "using module $module`n"
}


$SEPARATOR = "### ===================================================================================="


$textToAdd = @"


### Modules added with Append-UsingModuleStatements-IntoProfile.ps1
# Date when modules were added: $(Get-Date)
# Repository of the modules:    https://github.com/ElianFabian/powershell-utils
$SEPARATOR

$usingModuleStatments
$SEPARATOR
"@

Add-Content -Path $PROFILE -Value $textToAdd

Start-Process notepad $PROFILE
