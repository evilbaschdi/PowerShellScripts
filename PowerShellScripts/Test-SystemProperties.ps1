#Basic
Write-Output("## Basic ##")
#Computername
Write-Output("Computername: " + $env:COMPUTERNAME)
#Domain
$domain = (Get-CimInstance Win32_ComputerSystem).Domain
Write-Output("Domain: " + $domain)
#Current IP
$ipv4 = ((Test-Connection -ComputerName $env:COMPUTERNAME -Count 1).IPV4Address)
Write-Output("Current IP (v4): " + $ipv4)
$ipv6 = ((Test-Connection -ComputerName $env:COMPUTERNAME -Count 1).IPV6Address)
Write-Output("Current IP (v6): " + $ipv6)
#Productname:
$regkeypath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\"
$ReleaseId = ""
$ReleaseIdNull = $null -eq (Get-ItemProperty $regkeypath).ReleaseId
if ($ReleaseIdNull -eq $false) {
    $ReleaseId = " (Release " + (Get-ItemProperty $regkeypath).ReleaseId + ")"
}
Write-Output("Productname: " + (Get-CimInstance Win32_OperatingSystem).Caption + $ReleaseId)
#Architecture
Write-Output("Architecture: " + (Get-CimInstance Win32_OperatingSystem).OSArchitecture)
#Manufacturer
Write-Output("Manufacturer: " + (Get-CimInstance Win32_ComputerSystem).Manufacturer)
#Owner
$owner = (Get-CimInstance Win32_OperatingSystem).RegisteredUser
if ($null -ne $owner) {
    Write-Output("Owner: " + $owner)
}

#Windows
Write-Output("")
Write-Output("## Windows ##")
$BuildNumber = ""
$CurrentVersion = (Get-CimInstance Win32_OperatingSystem).Version
$CurrentVersionSplit = $CurrentVersion.Split('.')
$CurrentBuild = (Get-ItemProperty $regkeypath).CurrentBuild
$BuildLab = (Get-ItemProperty $regkeypath).BuildLab
$BuildLabEx = (Get-ItemProperty $regkeypath).BuildLabEx
$BuildLabExSplit = $BuildLabEx.Split('.')
$UbrNull = $null -eq (Get-ItemProperty $regkeypath).Ubr
if ( $UbrNull -eq $false ) {
    $Ubr = (Get-ItemProperty $regkeypath).UBR
    $BuildNumber = $CurrentBuild + "." + $Ubr
}
else {
    $BuildNumber = $BuildLabExSplit[0] + "." + $BuildLabExSplit[1]
}
#Version number
Write-Output("Version number: " + $CurrentVersionSplit[0] + "." + $CurrentVersionSplit[1] + " | Current build: " + $CurrentBuild + " (Build: " + $BuildNumber + ")")
#BuildLab
Write-Output("BuildLab: " + $BuildLab)
#BuildLabEx
Write-Output("BuildLabEx: " + $BuildLabEx)
#Display Driver
$displayDriver = Get-CimInstance Win32_VideoController | Select-Object -ExpandProperty Name
if ($null -ne $displayDriver) {
    Write-Output("Display Driver: " + $displayDriver)
}
#Memory
$memory = Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum
$memoryGB = [math]::Round($memory.Sum / 1GB, 2)
Write-Output("Memory: " + $memoryGB + " GB")
#Processor
$processor = Get-CimInstance Win32_Processor | Select-Object -ExpandProperty Name
Write-Output("Processor: " + $processor)

#History
Write-Output("")
Write-Output("## History ##")
$historyPath = "HKLM:\SYSTEM\Setup\Source OS"
if (Test-Path $historyPath) {
    $buildLabEx = (Get-ItemProperty $historyPath).BuildLabEx
    if ($null -ne $buildLabEx) {
        Write-Output("Previous Build: " + $buildLabEx)
    }
}

#.Net
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$dotNetScriptPath = Join-Path $scriptPath "Get-DotNetVersions.ps1"
if (Test-Path $dotNetScriptPath) {

    Write-Output("")
    Write-Output("## .Net ##")
    & $dotNetScriptPath

}

#Other
Write-Output("");
Write-Output("## Other ##");
#IE / Edge
$edgeregpath = "HKLM:\Software\Microsoft\Edge"
$EdgeNull = Test-Path $edgeregpath
if ($EdgeNull -eq $true) {
    $EdgeVersion = (Get-ItemProperty $edgeregpath).Version
    if ($null -ne $EdgeVersion) {
        Write-Output("Microsoft Edge: " + $EdgeVersion)
    }
}
$ieregpath = "HKLM:\Software\Microsoft\Internet Explorer"
$IeNull = $null -eq (Get-ItemProperty $ieregpath).svcVersion
if ( $IeNull -eq $false ) {
    $svcVersion = (Get-ItemProperty $ieregpath).svcVersion
    Write-Output("Internet Explorer: " + $svcVersion)
}
#Visual Studio Code
$vscodePath = "C:\Program Files\Microsoft VS Code\bin\code.cmd"
if (Test-Path $vscodePath) {
    $vscodeVersion = (Get-Item "C:\Program Files\Microsoft VS Code\Code.exe").VersionInfo.ProductVersion
    Write-Output("Visual Studio Code: " + $vscodeVersion)
}
#Visual Studio
$vsregpath = "HKLM:\SOFTWARE\Microsoft\VisualStudio\"
if (Test-Path $vsregpath) {
    $vsVersions = Get-ChildItem $vsregpath | Where-Object { $_.PSChildName -match '^\d+\.\d+$' } | Select-Object -ExpandProperty PSChildName
    if ($null -ne $vsVersions) {
        foreach ($version in $vsVersions) {
            Write-Output("Visual Studio: " + $version)
        }
    }
}
#PowerShell
Write-Output("PowerShell: " + $PSVersionTable.PSVersion)

#Git
if (Test-Path "C:\Program Files\Git\bin\git.exe") {
    $VersionInfo = (Get-Item "C:\Program Files\Git\bin\git.exe").VersionInfo
    $FileVersion = ("{0}.{1}.{2}.{3}" -f $VersionInfo.FileMajorPart,
        $VersionInfo.FileMinorPart,
        $VersionInfo.FileBuildPart,
        $VersionInfo.FilePrivatePart)
    Write-Output("Git for Windows: " + $FileVersion)
}

if (Test-Path "C:\Program Files (x86)\Git\bin\git.exe") {
    $VersionInfo = (Get-Item "C:\Program Files (x86)\Git\bin\git.exe").VersionInfo
    $FileVersion = ("{0}.{1}.{2}.{3}" -f $VersionInfo.FileMajorPart,
        $VersionInfo.FileMinorPart,
        $VersionInfo.FileBuildPart,
        $VersionInfo.FilePrivatePart)
    Write-Output("Git for Windows: " + $FileVersion)
}

Write-Output("")
Write-Output "Press any key to continue..."
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") > $null