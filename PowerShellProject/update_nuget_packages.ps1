$ProjectsPath = "C:\Git"
$Remote1Path = 'https://github.com/evilbaschdi/'
$Remote2Path = 'https://evilbaschdi.visualstudio.com/Main/_git/'

.\nuget.exe update -self


ForEach( $File in Get-ChildItem $ProjectsPath\*.sln -Recurse ) 
{
    Set-Location $File.Directory
    Write-Host $File.Fullname
    $path =$PSScriptRoot +"\nuget.exe"
    Start-Process -FilePath $path -ArgumentList 'restore',$File.Fullname -NoNewWindow -Wait

     $RemoteV = git remote -v  

     If ($RemoteV -like "*"+$Remote1Path +"*" -or $RemoteV -like "*"+$Remote2Path +"*") {


              Start-Process -FilePath $path -ArgumentList 'update',$File.Fullname -NoNewWindow -Wait
    #git commit
    git add .
    git commit -a -m 'updated nuget packages to their latest version'
            }                 




    
 }
 Set-Location $PSScriptRoot