$ProjectsPath = "C:\Git"
$Remote1Path = 'https://github.com/evilbaschdi/'
$Remote2Path = 'https://evilbaschdi@dev.azure.com/evilbaschdi/Main/_git/'
$Remote3Path = 'https://evilbaschdi.visualstudio.com/Main/_git/'




ForEach ($Directory in Get-ChildItem -Path $ProjectsPath) {
    If ($Directory.PSIsContainer -eq $True) {
        Set-Location $Directory.FullName
        
        If (Test-Path .\.git) {     
        $RemoteV = git remote -v        
            If ($RemoteV -like "*" + $Remote1Path + "*" -or $RemoteV -like "*" + $Remote2Path + "*" -or $RemoteV -like "*" + $Remote3Path + "*") {

            $DirectoryFullName = $Directory.FullName
                ForEach ( $File in Get-ChildItem $DirectoryFullName\*.csproj -Recurse ) {
  
                    Write-Output $File.Fullname
                    
                  
                        (Get-Content -path $File.Fullname -Raw).Replace('<Version>$([System.DateTime]::UtcNow.AddHours(2).ToString(yyyy.M.d.Hmm))</Version>', '<Version>$([System.DateTime]::UtcNow.ToString(yyyy.M.d.Hmm))</Version>').Trim() | Set-Content -Path $File.Fullname -Encoding UTF8
                                
               
                   
                    
                
                    Write-Output '--------------'
                }






                        git add .
                        git commit -am'.'

                        git push 




            }
        }
    }
}
Set-Location $PSScriptRoot