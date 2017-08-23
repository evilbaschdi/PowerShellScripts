#Install-Module -Name Invoke-MsBuild
$ProjectsPath = "C:\Git"

ForEach( $File in Get-ChildItem $ProjectsPath\*.sln -Recurse ) 
{
    Set-Location $File.Directory
    Write-Host $File.Fullname
    Invoke-MsBuild -Path $File.Fullname -Params "/t:Clean;Build /p:Configuration=Release" -ShowBuildOutputInCurrentWindow
 }
 Set-Location $PSScriptRoot