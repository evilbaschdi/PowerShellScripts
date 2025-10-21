Param([string]$ProjectsPath = 'C:\Git')
$NothingToCommit = 'nothing to commit'
$BranchBehind = 'Your branch is behind'

ForEach ($Directory in Get-ChildItem -Path $ProjectsPath) {
    If ($Directory.PSIsContainer -eq $True) {
        Set-Location $Directory.FullName
        Write-Output $Directory.Name
        If (Test-Path .\.git) {
            git fetch
            $GitStatus = git status
            If ($GitStatus -like "*" + $BranchBehind + "*" -and $GitStatus -like "*" + $NothingToCommit + "*") {
                Write-Output "Pulling changes from " $Directory.FullName
                git pull
            }
        }
    }
}


Set-Location $PSScriptRoot
Write-Output
Write-Output -NoNewLine "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
