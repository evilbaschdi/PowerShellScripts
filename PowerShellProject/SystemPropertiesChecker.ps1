#Basic
Write-Host("## Basic ##")
#Computername
Write-Host("Computername: " + $env:COMPUTERNAME)
#Current IP 
$ipv4=((Test-Connection -ComputerName $env:COMPUTERNAME -Count 1).IPV4Address)
Write-Host("Current IP (v4): " +$ipv4)
$ipv6=((Test-Connection -ComputerName $env:COMPUTERNAME -Count 1).IPV6Address)
Write-Host("Current IP (v6): " +$ipv6)
#Productname:
$regkeypath= "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\"
$ReleaseId = ""
$ReleaseIdNull = (Get-ItemProperty $regkeypath).ReleaseId -eq $null 
if($ReleaseIdNull -eq $false) {
    $ReleaseId = " (Release " + (Get-ItemProperty $regkeypath).ReleaseId+ ")"
}
Write-Host("Productname: " +(Get-WMIObject Win32_OperatingSystem).Caption +$ReleaseId)
#Architecture
Write-Host("Architecture: " +(Get-WMIObject Win32_OperatingSystem).OSArchitecture)
#Manufacturer
Write-Host("Manufacturer: " +(Get-WMIObject Win32_ComputerSystem).Manufacturer)

#Windows
Write-Host("")
Write-Host("## Windows ##")
$BuildNumber = ""
$CurrentVersion = (Get-WMIObject Win32_OperatingSystem).Version
$CurrentVersionSplit = $CurrentVersion.Split('.')
$CurrentBuild =(Get-ItemProperty $regkeypath).CurrentBuild
$BuildLab = (Get-ItemProperty $regkeypath).BuildLab
$BuildLabEx = (Get-ItemProperty $regkeypath).BuildLabEx
$BuildLabExSplit = $BuildLabEx.Split('.')
$UbrNull = (Get-ItemProperty $regkeypath).Ubr -eq $null 
if ( $UbrNull -eq $false ) {
    $Ubr = (Get-ItemProperty $regkeypath).UBR
    $BuildNumber = $CurrentBuild + "."+$Ubr
}
else {
    $BuildNumber = $BuildLabExSplit[0] + "."+$BuildLabExSplit[1]
}
#Version number
Write-Host("Version number: "+$CurrentVersionSplit[0] +"." +$CurrentVersionSplit[1]+" | Current build: "+$CurrentBuild+" (Build: "  +$BuildNumber+")")
#BuildLab
Write-Host("BuildLab: " + $BuildLab)
#BuildLabEx
Write-Host("BuildLabEx: " + $BuildLabEx)

#Other
Write-Host("");
Write-Host("## Other ##");
#IE
$ieregpath= "HKLM:\Software\Microsoft\Internet Explorer"
$IeNull = (Get-ItemProperty $ieregpath).svcVersion -eq $null 
if ( $IeNull -eq $false ) {
    $svcVersion = (Get-ItemProperty $ieregpath).svcVersion
    Write-Host("Internet Explorer: "+$svcVersion)
}
#PowerShell
Write-Host("PowerShell: "+$PSVersionTable.PSVersion)

#Git
if(Test-Path "C:\Program Files\Git\bin\git.exe") {
    $VersionInfo = (Get-Item "C:\Program Files\Git\bin\git.exe").VersionInfo
    $FileVersion = ("{0}.{1}.{2}.{3}" -f $VersionInfo.FileMajorPart, 
        $VersionInfo.FileMinorPart, 
        $VersionInfo.FileBuildPart, 
        $VersionInfo.FilePrivatePart)
    Write-Host("Git for Windows: "+ $FileVersion)
}

if(Test-Path "C:\Program Files (x86)\Git\bin\git.exe") {
    $VersionInfo = (Get-Item "C:\Program Files (x86)\Git\bin\git.exe").VersionInfo
    $FileVersion = ("{0}.{1}.{2}.{3}" -f $VersionInfo.FileMajorPart, 
        $VersionInfo.FileMinorPart, 
        $VersionInfo.FileBuildPart, 
        $VersionInfo.FilePrivatePart)
    Write-Host("Git for Windows: "+ $FileVersion)
}

#.Net
if(Test-Path .\GetDotNetVersions.ps1) {

    Write-Host("")
    Write-Host("## .Net ##")
    .\GetDotNetVersions.ps1

}
else {
Write-Host("")
Write-Host "Press any key to continue..."
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") > $null
}
