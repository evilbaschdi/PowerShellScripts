#
# SyncGitRemotes.ps1
#
# Please set 'origin' and 'vsts' to fit your environment

Param([string]$ProjectsPath = 'C:\Git')

$Remote1Name = 'origin'
$Remote1Path = '*://github.com/evilbaschdi/'
$Remote2Name = 'vsts'
$Remote2Path = 'https://evilbaschdi.visualstudio.com/'

function Git-Sync {
    # Set 'origin' and 'vsts' to fit your environment
    git fetch $Remote1Name --tags
    git fetch $Remote2Name --tags
    git push $Remote1Name --all
    git push $Remote1Name --tags
    git push $Remote2Name --all
    git push $Remote2Name --tags    
}

ForEach ($Directory in Get-ChildItem -Path $ProjectsPath) {
    If ($Directory.PSIsContainer -eq $True) {
        Set-Location $Directory.FullName
        
        If (Test-Path .\.git) {
            Write-Output $Directory.FullName
            $RemoteV = git remote -v  
            #Write-Output $RemoteV
            # Remove $Remote2Name    
            <#      
            If ($RemoteV -like "*"+$Remote2Name+"*") {
                git remote rm $Remote2Name
            }
              #>

            # Add new Remote $Remote2Name to repository
            If ($RemoteV -like "*" + $Remote1Path + "*" -and !($RemoteV -like "*" + $Remote2Path + "*")) {       
                $AddRemoteGit = git remote add $Remote2Name $Remote2Path$Directory      
                Write-Output $AddRemoteGit
            }

            # Sync both repos
            If ($RemoteV -like "*" + $Remote1Path + "*" -and $RemoteV -like "*" + $Remote2Path + "*") {  
                
                Write-Output "Sync repos"
                $GitSync = Git-Sync du 2>&1 | ForEach-Object { "$_" }
                Write-Output $GitSync                
            }
            Else {
                #Write-Output no fitting repos found
            }           
        }
    }
}
Set-Location $PSScriptRoot