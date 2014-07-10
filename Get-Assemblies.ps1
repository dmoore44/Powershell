# Modify the $searchtext variable to search for various .net assemblies
$searchtext = "*SQL*"
[AppDomain]::CurrentDomain.GetAssemblies() | ForEach-Object { $_.GetExportedTypes() } | Where-Object { $_ -like $searchtext } | ForEach-Object { $_.FullName } | Sort
