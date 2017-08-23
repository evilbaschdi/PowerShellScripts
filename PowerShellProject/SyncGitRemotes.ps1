#
# SyncGitRemotes.ps1
#
# Please set 'origin' and 'vsts' to fit your environment
$ProjectsPath = 'C:\dev'
$Remote1Name = 'origin'
$Remote1Path = 'https://github.com/evilbaschdi/'
$Remote2Name = 'vsts'
$Remote2Path = 'https://evilbaschdi.visualstudio.com/Main/_git/'

function Git-Sync{
# Set 'origin' and 'vsts' to fit your environment
    git fetch origin --tags
    git fetch vsts --tags
    git push origin --all
    git push origin --tags
    git push vsts --all
    git push vsts --tags
}

ForEach ($Directory in Get-ChildItem -Path $ProjectsPath) {
    If ($Directory.PSIsContainer -eq $True) {
        Set-Location $Directory.FullName
        If (Test-Path .\.git) {
            Write-Host $Directory.FullName
            $RemoteV = git remote -v  
            # Remove $Remote2Name    
                 <#      
            If ($RemoteV -like "*"+$Remote2Name+"*") {
                git remote rm $Remote2Name
            }
              #>
            If ($RemoteV -like "*"+$Remote1Path +"*" -and $RemoteV -like "*"+$Remote2Path +"*") {
                # Add new Remote $Remote2Name to repository
                <#
                $AddRemoteGit = git remote add $Remote2Name $Remote2Path$Directory      
                Write-Host $AddRemoteGit
                #>
                # Sync both repos      
                Write-Host Sync repos
               $GitSync =Git-Sync du 2>&1 | %{ "$_" }
                Write-Host $GitSync
            }            
        }
    }
}
Set-Location $PSScriptRoot