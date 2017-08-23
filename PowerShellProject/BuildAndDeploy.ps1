#Install-Module -Name Invoke-MsBuild
$ProjectsPath = "C:\Git"
$Remote1Path = 'https://github.com/evilbaschdi/'
$Remote2Path = 'https://evilbaschdi.visualstudio.com/Main/_git/'

ForEach ( $File in Get-ChildItem $ProjectsPath\*.sln -Recurse ) {
    Set-Location $File.Directory
    Write-Host $File.Fullname

    $RemoteV = git remote -v  

    If ($RemoteV -like "*" + $Remote1Path + "*" -or $RemoteV -like "*" + $Remote2Path + "*") {
        Invoke-MsBuild -Path $File.Fullname -Params "/t:Clean;Build /p:Configuration=Release" -ShowBuildOutputInCurrentWindow
    }
    Else {
        Write-Host no fitting repos found
    }              
}
Set-Location $PSScriptRoot