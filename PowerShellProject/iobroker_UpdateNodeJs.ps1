Find-Module PoSH-SSH | Install-Module -Scope CurrentUser
New-SSHSession -ComputerName x-raspberrypi1 -Credential pi

#cd /opt/iobroker
$stream = Invoke-SSHCommand -SessionId 0 -Command "cd /opt/iobroker"
Write-Information $stream
#sudo iobroker stop
$stream = Invoke-SSHCommand -SessionId 0 -Command "sudo iobroker stop"
Write-Information $stream
#curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
$stream = Invoke-SSHCommand -SessionId 0 -Command "curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -"
Write-Information $stream
#sudo apt install -y nodejs
$stream = Invoke-SSHCommand -SessionId 0 -Command "sudo apt install -y nodejs"
Write-Information $stream
#sudo iobroker fix
$stream = Invoke-SSHCommand -SessionId 0 -Command "sudo iobroker fix"
Write-Information $stream
#sudo iobroker start
$stream = Invoke-SSHCommand -SessionId 0 -Command "sudo iobroker start"
Write-Information $stream