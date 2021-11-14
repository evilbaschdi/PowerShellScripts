$pwshRegPath = "HKLM:\SOFTWARE\Microsoft\PowerShellCore"
$previewPath = Join-Path -Path $pwshRegPath -ChildPath "InstalledVersions\39243d76-adaf-42b1-94fb-16ecf83237c8"
if (!(Test-Path -Path $previewPath)) {
    throw "PowerShell 7 Preview is not installed"
}

Set-ItemProperty -Path $pwshRegPath -Name UseMU -Value 0 -Type DWord
Set-ItemProperty -Path $previewPath -Name Install -Value 0 -Type DWord