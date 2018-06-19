$ErrorActionPreference= 'silentlycontinue'
Write-Output (Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -recurse |
Get-ItemProperty -name Version,Release -EA 0 |
Where-Object { $_.PSChildName -match '^(?!S)\p{L}'} |
Select-Object PSChildName, Version, Release, @{
  name="Product"
  expression={
	  switch($_.Release) {
		378389 { [Version]"4.5" }
		378675 { [Version]"4.5.1" }
		378758 { [Version]"4.5.1" }
		379893 { [Version]"4.5.2" }
		393295 { [Version]"4.6" }
		393297 { [Version]"4.6" }
		394254 { [Version]"4.6.1" }
		394271 { [Version]"4.6.1" }
		394802 { [Version]"4.6.2" }
		394806 { [Version]"4.6.2" }
		460798 { [Version]"4.7" }
		460805 { [Version]"4.7" }
		461308 { [Version]"4.7.1" }
		461310 { [Version]"4.7.1" }
		461808 { [Version]"4.7.2" }
		461814 { [Version]"4.7.2" }
	  }
	}
} | Format-Table | Out-String)
$blankLine = "`n"
#dotnet core runtimes
$runtimes = dotnet --list-runtimes |Out-String
if(!$runtimes.StartsWith("."))
{
Write-Output "dotnet core runtimes"
Write-Output "--------------------"
Write-Output $runtimes
Write-Output $blankLine
}
#dotnet core sdks
$sdks = dotnet --list-sdks |Out-String
if(!$sdks.StartsWith("."))
{
Write-Output "dotnet core sdks"
Write-Output "----------------"
Write-Output $sdks
Write-Output $blankLine
}
#dotnet core versions - pre 2.1
#todo if empty "runtimes" and "sdks"
$version = dotnet --version |Out-String
if(($runtimes.StartsWith(".") -or $sdks.StartsWith(".")) -and !$version.StartsWith("."))
{
Write-Output "dotnet core version"
Write-Output "-------------------"
Write-Output $version
Write-Output $blankLine
}
Write-Output "Press any key to continue..."
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") > $null
