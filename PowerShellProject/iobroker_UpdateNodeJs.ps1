Find-Module PoSH-SSH | Install-Module -Scope CurrentUser
New-SSHSession -ComputerName x-raspberrypi1 -Credential pi

#cd /opt/iobroker
$stream = Invoke-SSHCommand -SessionId 0 -Command "cd /opt/iobroker"
#Write-Information $sshCommand.Read()
#sudo iobroker stop
$stream = Invoke-SSHCommand -SessionId 0 -Command "sudo iobroker stop"
#Write-Information $sshCommand.Read()
#curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
$stream = Invoke-SSHCommand -SessionId 0 -Command "curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -"
#Write-Information $sshCommand.Read()
#sudo apt install -y nodejs
$stream = Invoke-SSHCommand -SessionId 0 -Command "sudo apt install -y nodejs"
#Write-Information $sshCommand.Read()
#node -v
$stream = Invoke-SSHCommand -SessionId 0 -Command "node -v"
#Write-Information $sshCommand.Read()
#curl -sL https://iobroker.net/fix.sh | bash -
$stream = Invoke-SSHCommand -SessionId 0 -Command "curl -sL https://iobroker.net/fix.sh | bash -"
#Write-Information $sshCommand.Read()
#npm rebuild
$stream = Invoke-SSHCommand -SessionId 0 -Command "npm rebuild"
#Write-Information $sshCommand.Read()
#sudo iobroker start
$stream = Invoke-SSHCommand -SessionId 0 -Command "sudo iobroker start"
#Write-Information $sshCommand.Read()