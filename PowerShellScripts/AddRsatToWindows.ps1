Get-WindowsCapability -Online | Where-Object { $_.Name -like "*RSAT*" -and $_.State -eq "NotPresent" } | Add-WindowsCapability -Online
