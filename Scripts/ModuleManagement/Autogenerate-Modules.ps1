# Autogenerate-Modules.ps1



# From repository: https://github.com/ElianFabian/powershell-utils



# Generats the enums from the modules to create a file to add them and then import then with the using statement.
# We do this because in Powershell you can't export an enum.



function New-AutogenaratedModule($ModuleName, $DataTypeRegex, $DataTypeName)
{
    $filesToReadTheirPossibleDataTypes = Get-ChildItem -Path ..\..\Modules\* -Exclude "$ModuleName.psm1" -File -Recurse

    $thisFileName = [System.IO.Path]::GetFileName($PSCommandPath)

    $lineSeparator = "`n`n`n"

    $initialTextInAutogeneratedFile = @(
        "# $ModuleName.psm1",
        "# This file was generated by $thisFileName",
        "# This file will be imported in $PROFILE with a 'using' statement to use its $DataTypeName set", ''
    ) -join $lineSeparator

    $autogeneratedFileContent = [System.Text.StringBuilder]::new($initialTextInAutogeneratedFile)

    foreach ($file in $filesToReadTheirPossibleDataTypes)
    {
        $content = Get-Content $file -Raw

        $dataTypes = (Select-String -InputObject $content -Pattern $DataTypeRegex -AllMatches).Matches

        if ($dataTypes.Count -eq 0) { continue }

        $autogeneratedFileContent.Append("#region From: $($file.Name)").Append("`n`n")

        foreach($dataType in $dataTypes)
        {
            $autogeneratedFileContent.Append($dataType).Append("`n`n")
        }

        $autogeneratedFileContent.Append("#endregion$lineSeparator")
    }

    New-Item -Path "../../Modules/AutogeneratedModules/$ModuleName/$ModuleName.psm1" -Value $autogeneratedFileContent.ToString() -ItemType File -Force 
}



New-AutogenaratedModule -ModuleName "EnumModule" -DataTypeName "enum" -DataTypeRegex "enum \w+\s*\n?{[\S\s]*?}"
