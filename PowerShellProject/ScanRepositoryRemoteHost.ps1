$ProjectsPath = 'C:\Git'
$RemoteName = 'git.fwi.at'

ForEach ($Directory in Get-ChildItem -Path $ProjectsPath) {
    If ($Directory.PSIsContainer -eq $True) {
        Set-Location $Directory.FullName
        If (Test-Path .\.git) {           
            $RemoteV = git remote -v  
              
            If ($RemoteV -like "*" + $RemoteName + "*") {
                Write-Host $RemoteV
                Write-Host $Directory.FullName
            }              
              
        }
    }
}

Write-Host -NoNewLine "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")