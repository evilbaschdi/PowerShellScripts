$AllBuilds = $(Get-ChildItem "HKLM:\System\Setup" | Where-Object { $_.Name -match "\\Source\s" }) | ForEach-Object { $_ | Select-Object @{n = "UpdateTime"; e = { if ($_.Name -match "Updated\son\s(\d{1,2}\/\d{1,2}\/\d{4}\s\d{2}:\d{2}:\d{2})\)$") { [dateTime]::Parse($Matches[1], ([Globalization.CultureInfo]::CreateSpecificCulture('en-US'))) } } }, @{n = "ReleaseID"; e = { $_.GetValue("ReleaseID") } }, @{n = "Branch"; e = { $_.GetValue("BuildBranch") } }, @{n = "Build"; e = { $_.GetValue("CurrentBuild") } }, @{n = "ProductName"; e = { $_.GetValue("ProductName") } }, @{n = "InstallTime"; e = { [datetime]::FromFileTime($_.GetValue("InstallTime")) } } };
$AllBuilds | Sort-Object UpdateTime | ForEach-Object { "$($_.UpdateTime) | $($_.ReleaseId) | $($_.Branch) | $($_.Build) | $($_.ProductName)" }