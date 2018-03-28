Param([string]$ProjectsPath = 'C:\Git')
$Remote1Path = 'https://github.com/evilbaschdi/'
$Remote2Path = 'https://evilbaschdi.visualstudio.com/Main/_git/'
$NothingToCommit = 'nothing to commit'
$BranchAhead = 'Your branch is ahead'

ForEach ($Directory in Get-ChildItem -Path $ProjectsPath) {
    If ($Directory.PSIsContainer -eq $True) {
        Set-Location $Directory.FullName
        Write-Host $Directory.Name
        If (Test-Path .\.git) {
            $RemoteV = git remote -v  
            If ($RemoteV -like "*" + $Remote1Path + "*" -or $RemoteV -like "*" + $Remote2Path + "*") {
            git fetch
            $GitStatus = git status           
            If ($GitStatus -like "*" + $BranchAhead + "*" -and $GitStatus -like "*" + $NothingToCommit + "*") {     
                Write-Host "Pushing changes for " $Directory.FullName  
                git push
            }                   
        }}
    }
}


Set-Location $PSScriptRoot
Write-Host
Write-Host -NoNewLine "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")