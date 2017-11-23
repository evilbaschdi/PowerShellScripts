Param([string]$ProjectsPath = 'C:\Git')
$NothingToCommit = 'nothing to commit'
$BranchBehind = 'Your branch is behind'

ForEach ($Directory in Get-ChildItem -Path $ProjectsPath) {
    If ($Directory.PSIsContainer -eq $True) {
        Set-Location $Directory.FullName
        If (Test-Path .\.git) {
            $GitStatus = git status           
            If ($GitStatus -like "*" + $BranchBehind + "*" -and $GitStatus -like "*" + $NothingToCommit + "*") {     
                Write-Host "Pulling changes from " $Directory.FullName  
                git pull
            }                   
        }
    }
}


Set-Location $PSScriptRoot
Write-Host
Write-Host -NoNewLine "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")