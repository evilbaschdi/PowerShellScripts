Param([string]$ProjectsPath = 'C:\Git')
$Remote1Path = 'https://github.com/evilbaschdi/'
$Remote2Path = 'https://evilbaschdi@dev.azure.com/evilbaschdi/Main/_git/'
$Remote3Path = 'https://evilbaschdi.visualstudio.com/Main/_git/'
$NothingToCommit = 'nothing to commit'
$BranchAhead = 'Your branch is ahead'

ForEach ($Directory in Get-ChildItem -Path $ProjectsPath) {
    If ($Directory.PSIsContainer -eq $True) {
        Set-Location $Directory.FullName
        Write-Output $Directory.Name
        If (Test-Path .\.git) {
            $RemoteV = git remote -v
            If ($RemoteV -like "*" + $Remote1Path + "*" -or $RemoteV -like "*" + $Remote2Path + "*" -or $RemoteV -like "*" + $Remote3Path + "*") {
                git fetch
                $GitStatus = git status
                If ($GitStatus -like "*" + $BranchAhead + "*" -and $GitStatus -like "*" + $NothingToCommit + "*") {
                    Write-Output "Pushing changes for " $Directory.FullName
                    git push origin
                    git push azuredevops
                }
            }
        }
    }
}


Set-Location $PSScriptRoot
Write-Output
Write-Output -NoNewLine "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")