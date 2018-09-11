Param([string]$ProjectsPath = 'C:\Git')

$OldRemotePath = 'https://fwigroupcrm.visualstudio.com/FWI%20DE/_git/'
$NewRemotePath = 'https://fwigroupcrm@dev.azure.com/fwigroupcrm/FWI%20DE/_git/'

ForEach ($Directory in Get-ChildItem -Path $ProjectsPath) {
    If ($Directory.PSIsContainer -eq $True) {
        Set-Location $Directory.FullName
        
        If (Test-Path .\.git) {
           $OldOrigin = git config --get remote.origin.url
                      
            If ($OldOrigin -like "*"+$OldRemotePath+"*") {
                Write-Output $Directory.FullName
            
                $NewOrigin = $OldOrigin.Replace($OldRemotePath, $NewRemotePath)
            
                $RenameGitRemote = git remote rename origin old_origin
                Write-Output $RenameGitRemote

                $AddGitRemote = git remote add origin $NewOrigin
                Write-Output $AddGitRemote
            }   
        }
    }
}
Set-Location $PSScriptRoot