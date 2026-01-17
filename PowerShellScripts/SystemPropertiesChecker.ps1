#Basic
Write-Output("## Basic ##")
#Computername
Write-Output("Computername: " + $env:COMPUTERNAME)
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

#Other
Write-Output("");
Write-Output("## Other ##");
#IE
$ieregpath = "HKLM:\Software\Microsoft\Internet Explorer"
$IeNull = $null -eq (Get-ItemProperty $ieregpath).svcVersion
if ( $IeNull -eq $false ) {
    $svcVersion = (Get-ItemProperty $ieregpath).svcVersion
    Write-Output("Internet Explorer: " + $svcVersion)
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

#.Net
if (Test-Path .\GetDotNetVersions.ps1) {

    Write-Output("")
    Write-Output("## .Net ##")
    .\GetDotNetVersions.ps1

}
else {
    Write-Output("")
    Write-Output "Press any key to continue..."
    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") > $null
}
