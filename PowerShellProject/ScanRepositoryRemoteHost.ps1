$ProjectsPath = 'C:\Git'
$RemoteName = 'git.fwi.at'

ForEach ($Directory in Get-ChildItem -Path $ProjectsPath) {
    If ($Directory.PSIsContainer -eq $True) {
        Set-Location $Directory.FullName
        If (Test-Path .\.git) {
            $RemoteV = git remote -v

            If ($RemoteV -like "*" + $RemoteName + "*") {
                Write-Output $RemoteV
                Write-Output $Directory.FullName
            }

        }
    }
}

Write-Output -NoNewLine "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")