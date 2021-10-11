Param([string]$ProjectsPath = 'C:\Git')
$NothingToCommit = 'nothing to commit'
$BranchAhead = 'Your branch is ahead'

$ChangesToCommitArray = New-Object System.Collections.ArrayList
$BranchAheadArray = New-Object System.Collections.ArrayList

ForEach ($Directory in Get-ChildItem -Path $ProjectsPath) {
    If ($Directory.PSIsContainer -eq $True) {
        Set-Location $Directory.FullName
        If (Test-Path .\.git) {
            $GitDiff = git diff HEAD
            If ($GitDiff -inotlike "") {              
                Write-Output $Directory.FullName
            }
        }
    }
}

Set-Location $PSScriptRoot
Write-Output
Write-Output -NoNewLine "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")