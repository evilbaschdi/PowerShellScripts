$json = $((Get-Content ".\DotNetVersionReleaseKeyMapping.json" -Raw) | ConvertFrom-Json).PSObject.Properties

$ErrorActionPreference = 'silentlycontinue'
Write-Output (Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -recurse |
    Get-ItemProperty -name Version, Release -EA 0 |
    Where-Object { $_.PSChildName -match '^(?!S)\p{L}' } |
    Select-Object PSChildName, Version, Release, @{
      name       = "Product"
      expression = {
        if ($_.Release) {
          $releaseKey = ($json | Where-Object Name -Match $_.Release).Value
          $releaseKey
        }
      }
    } | Format-Table | Out-String)
$blankLine = "`n"
#dotnet core runtimes
$runtimes = dotnet --list-runtimes | Out-String
if (!$runtimes.StartsWith(".")) {
  Write-Output "dotnet core runtimes"
  Write-Output "--------------------"
  Write-Output $runtimes
  Write-Output $blankLine
}
#dotnet core sdks
$sdks = dotnet --list-sdks | Out-String
if (!$sdks.StartsWith(".")) {
  Write-Output "dotnet core sdks"
  Write-Output "----------------"
  Write-Output $sdks
  Write-Output $blankLine
}
#dotnet core versions - pre 2.1
#todo if empty "runtimes" and "sdks"
$version = dotnet --version | Out-String
if (($runtimes.StartsWith(".") -or $sdks.StartsWith(".")) -and !$version.StartsWith(".")) {
  Write-Output "dotnet core version"
  Write-Output "-------------------"
  Write-Output $version
  Write-Output $blankLine
}
Write-Output "Press any key to continue..."
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") > $null
