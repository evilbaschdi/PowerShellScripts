Find-Module PoSH-SSH | Install-Module -Scope CurrentUser
New-SSHSession -ComputerName x-raspberrypi1 -Credential pi

$stream = Invoke-SSHCommand -SessionId 0 -Command "iobroker stop && iobroker update && iobroker upgrade self && iobroker start"
#Write-Information $sshCommand.Read()