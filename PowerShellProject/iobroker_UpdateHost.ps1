Find-Module PoSH-SSH | Install-Module -Scope CurrentUser
New-SSHSession -ComputerName x-raspberrypi1 -Credential pi

$stream = Invoke-SSHCommand -SessionId 0 -Command "cd /opt/iobroker && iob backup && iob stop && iob update && iob upgrade self && iob fix && iob start"
Write-Information $stream