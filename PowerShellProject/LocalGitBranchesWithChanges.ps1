Param([string]$ProjectsPath = 'C:\Git')
$NothingToCommit = 'nothing to commit'
$BranchAhead = 'Your branch is ahead'

$ChangesToCommitArray = New-Object System.Collections.ArrayList
$BranchAheadArray = New-Object System.Collections.ArrayList

ForEach ($Directory in Get-ChildItem -Path $ProjectsPath) {
    If ($Directory.PSIsContainer -eq $True) {
        Set-Location $Directory.FullName
        If (Test-Path .\.git) {
                        $GitStatus = git status           
            If ($GitStatus -like "*" + $NothingToCommit + "*") {       
                If ($GitStatus -like "*" + $BranchAhead + "*") {      
                  
                    $BranchAheadArray.Add($Directory.FullName) > $null
                }   
            }     
            Else {             
                $ChangesToCommitArray.Add($Directory.FullName) > $null
            }         
        }
    }
}

Write-Host $BranchAhead
ForEach ($BranchAheadArrayItem in $BranchAheadArray) {
    Write-Host $BranchAheadArrayItem
}
Write-Host
Write-Host "Changes to commit"
ForEach ($ChangesToCommitArrayItem in $ChangesToCommitArray) {
    Write-Host $ChangesToCommitArrayItem
}

Set-Location $PSScriptRoot
Write-Host
Write-Host -NoNewLine "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")