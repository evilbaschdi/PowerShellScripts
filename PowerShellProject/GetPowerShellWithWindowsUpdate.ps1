$pwshRegPath = "HKLM:\SOFTWARE\Microsoft\PowerShellCore"
if (!(Test-Path -Path $pwshRegPath)) {
    throw "PowerShell 7 is not installed"
}

Set-ItemProperty -Path $pwshRegPath -Name UseMU -Value 1 -Type DWord

$pwshRegPath = "HKLM:\SOFTWARE\Microsoft\PowerShellCore"
$previewPath = Join-Path -Path $pwshRegPath -ChildPath "InstalledVersions\39243d76-adaf-42b1-94fb-16ecf83237c8"
if (!(Test-Path -Path $previewPath)) {
    $null = New-Item -Path $previewPath -ItemType Directory -Force
}

Set-ItemProperty -Path $pwshRegPath -Name UseMU -Value 1 -Type DWord
Set-ItemProperty -Path $previewPath -Name Install -Value 1 -Type DWord