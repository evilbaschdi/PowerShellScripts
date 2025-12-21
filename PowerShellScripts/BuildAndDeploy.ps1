$ProjectsPath = "C:\Git"

$Remote1Path = 'https://github.com/evilbaschdi/'
$Remote2Path = 'https://evilbaschdi@dev.azure.com/evilbaschdi/Main/_git/'

ForEach ($File in Get-ChildItem -Path $ProjectsPath -Filter publish.ps1 -Recurse -ErrorAction SilentlyContinue -Force) {
    Set-Location $File.Directory
    Write-Output $File.Fullname

    $RemoteV = git remote -v

    If ($RemoteV -like "*" + $Remote1Path + "*" -or $RemoteV -like "*" + $Remote2Path + "*") {
        & $File
    }
    Else {
        Write-Output no fitting repos found
    }
}
Set-Location $PSScriptRoot
