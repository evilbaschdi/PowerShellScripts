#Install-Module -Name Invoke-MsBuild
$ProjectsPath = "C:\Git"

.\nuget.exe update -self

$Remote1Path = 'https://github.com/evilbaschdi/'
$Remote2Path = 'https://evilbaschdi.visualstudio.com/Main/_git/'

ForEach ( $File in Get-ChildItem $ProjectsPath\*.sln -Recurse ) {
    Set-Location $File.Directory
    Write-Output $File.Fullname

    $RemoteV = git remote -v

    If ($RemoteV -like "*" + $Remote1Path + "*" -or $RemoteV -like "*" + $Remote2Path + "*") {
        $path = $PSScriptRoot + "\nuget.exe"
        Start-Process -FilePath $path -ArgumentList 'restore', $File.Fullname -NoNewWindow -Wait
        Invoke-MsBuild -Path $File.Fullname -Params "/t:Clean;Build /p:Configuration=Release /p:Platform=""Any CPU""" -ShowBuildOutputInCurrentWindow
    }
    Else {
        Write-Output no fitting repos found
    }
}
Set-Location $PSScriptRoot
