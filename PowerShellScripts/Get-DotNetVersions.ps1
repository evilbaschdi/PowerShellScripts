$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$jsonPath = Join-Path $scriptPath "DotNetVersionReleaseKeyMapping.json"
$json = $((Get-Content $jsonPath -Raw) | ConvertFrom-Json).PSObject.Properties

$ErrorActionPreference = 'SilentlyContinue'

# .NET Framework versions
Write-Output (Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' -Recurse |
  Get-ItemProperty -Name Version, Release -ErrorAction SilentlyContinue |
  Where-Object { $_.PSChildName -match '^(?!S)\p{L}' } |
  Select-Object PSChildName, Version, Release, @{
    Name       = "Product"
    Expression = {
      if ($_.Release) {
        ($json | Where-Object Name -Match $_.Release).Value
      }
    }
  } | Format-Table | Out-String)

# .NET Core/5+ Runtimes
$runtimes = dotnet --list-runtimes 2>$null | Out-String
if ($runtimes -and -not $runtimes.StartsWith(".")) {
  Write-Output ".NET Core Runtimes"
  Write-Output "------------------"
  Write-Output $runtimes
}

# .NET Core/5+ SDKs
$sdks = dotnet --list-sdks 2>$null | Out-String
if ($sdks -and -not $sdks.StartsWith(".")) {
  Write-Output ".NET Core SDKs"
  Write-Output "---------------"
  Write-Output $sdks
}

# .NET Version (for pre-2.1 versions)
$version = dotnet --version 2>$null | Out-String
if ($version -and -not $version.StartsWith(".") -and ($runtimes.StartsWith(".") -or $sdks.StartsWith("."))) {
  Write-Output ".NET Version"
  Write-Output "-------------"
  Write-Output $version
}

