# Export all functions in the Public folder
Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 | ForEach-Object {
    . $_.FullName
}
Export-ModuleMember -Function (Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 | 
    ForEach-Object {
        $_.BaseName
    }
)