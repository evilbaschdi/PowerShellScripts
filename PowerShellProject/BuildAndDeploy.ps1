#Install-Module -Name Invoke-MsBuild
$ProjectsPath = "C:\Git"

.\nuget.exe update -self

ForEach( $File in Get-ChildItem $ProjectsPath\*.sln -Recurse ) 
{
    Set-Location $File.Directory
    Write-Host $File.Fullname

    $path =$PSScriptRoot +"\nuget.exe"
    Start-Process -FilePath $path -ArgumentList 'restore',$File.Fullname -NoNewWindow -Wait
    Invoke-MsBuild -Path $File.Fullname -Params "/t:Clean;Build /p:Configuration=Release /p:Platform=""Any CPU""" -ShowBuildOutputInCurrentWindow
 }
 Set-Location $PSScriptRoot