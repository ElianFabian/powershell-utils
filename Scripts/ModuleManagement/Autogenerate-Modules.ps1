# Autogenerate-Modules.ps1



# Generates the data types (enums or classes) from the modules to create a file to add them and then import then with the using statement.
# We do this because in Powershell you can't export enum nor classes.


$AUTOGENERATED_FOLDER_NAME = "AutogeneratedModules"

#region Autogenerate implicitly from modules

function New-AutogenaratedModule($ModuleName, $DataTypeRegex, $DataTypeName)
{
    $lineSeparator = "`n`n`n" 

    $initialAutogeneratedFileText = @(
        "# $ModuleName.psm1",
        "# This file was generated by '$PSCommandPath' from other modules implicitly",
        "# This file must be imported in '$PROFILE' with a 'using' statement to be able to use its $DataTypeName set",
        "# To add it as a 'using' statement you have to execute 'Setup.ps1' or 'Autogenerate-Modules.ps1'",''
    ) -join $lineSeparator

    $autogeneratedFileSB = [System.Text.StringBuilder]::new($initialAutogeneratedFileText)

    $filesToReadTheirPossibleDataTypes = Get-ChildItem -Path ..\..\Modules\* -File -Recurse | Where-Object {

        $_.DirectoryName -notmatch $AUTOGENERATED_FOLDER_NAME
    }

    foreach ($moduleFile in $filesToReadTheirPossibleDataTypes)
    {
        $content = Get-Content $moduleFile -Raw

        $dataTypes = (Select-String -InputObject $content -Pattern $DataTypeRegex -AllMatches).Matches

        if ($dataTypes.Count -eq 0) { continue }

        $autogeneratedFileSB.Append("#region From: $($moduleFile.Name)").Append("`n`n") > $null

        foreach($dataType in $dataTypes)
        {
            $autogeneratedFileSB.Append($dataType).Append("`n`n") > $null
        }

        $autogeneratedFileSB.Append("#endregion$lineSeparator") > $null
    }

    # If no data type was added then we don't have to create the module
    if ($autogeneratedFileSB.ToString() -eq $initialAutogeneratedFileText) { return }

    New-Item -Path "../../Modules/$AUTOGENERATED_FOLDER_NAME/$ModuleName/$ModuleName.psm1" -Value $autogeneratedFileSB.ToString() -ItemType File -Force
}


New-AutogenaratedModule -ModuleName "AutogeneratedEnumModule" -DataTypeName "enum" -DataTypeRegex "enum \w+\s*\n?{[\S\s]*?}"

#endregion

#region Autogenerate explicitly from modules

$autogeneratedFileFromModulesSB = [System.Text.StringBuilder]::new("### This file was generated by '$PSCommandPath' from other modules explicitly`n`n`n")

$autogenerateFiles = (Get-ChildItem -Path "../../Modules/" -Filter "_Autogenerate.ps1" -File -Recurse).FullName

foreach($filePath in $autogenerateFiles)
{
    $autogenerateContent = & $filePath

    $autogeneratedFileFromModulesSB.Append("#region From: $($filePath)").Append("`n`n") > $null
    $autogeneratedFileFromModulesSB.Append($autogenerateContent).Append("`n") > $null
    $autogeneratedFileFromModulesSB.Append("#endregion`n`n`n") > $null
}

$autogeneratedFileFromModulesPath = "../../Modules/$AUTOGENERATED_FOLDER_NAME/AutogeneratedFromModules/AutogeneratedFromModules.psm1"

New-Item -Path $autogeneratedFileFromModulesPath -Value $autogeneratedFileFromModulesSB.ToString() -Force 

#endregion
