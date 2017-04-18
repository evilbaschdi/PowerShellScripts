$ProjectsPath = "C:\dev"

.\nuget.exe update -self


ForEach( $File in Get-ChildItem $ProjectsPath\*.sln -Recurse ) 
{
    Set-Location $File.Directory
    Write-Host $File.Fullname
    $path =$PSScriptRoot +"\nuget.exe"
    Start-Process -FilePath $path -ArgumentList 'restore',$File.Fullname -NoNewWindow -Wait
    Start-Process -FilePath $path -ArgumentList 'update',$File.Fullname -NoNewWindow -Wait
    #git commit
    git add .
    git commit -a -m 'updated nuget packages to their latest version'
 }
 Set-Location $PSScriptRoot