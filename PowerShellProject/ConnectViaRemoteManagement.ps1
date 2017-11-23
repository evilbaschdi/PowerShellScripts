$RemoteComputerName = "nanoserver1"
$UserName = "Administrator"
$IsHyperV = $false

net start WinRM
Set-Item WSMan:\localhost\Client\TrustedHosts -Value $RemoteComputerName
if ($IsHyperV) {
    Enter-PSSession -VMName $RemoteComputerName -Credential $UserName
}
else {
    Enter-PSSession -ComputerName $RemoteComputerName -Credential $UserName
}