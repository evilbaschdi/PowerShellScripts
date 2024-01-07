$ProjectsPath = "C:\Git"

ForEach ($Directory in Get-ChildItem -Path $ProjectsPath) {
    If ($Directory.PSIsContainer -eq $True) {
        Set-Location $Directory.FullName

        $DirectoryFullName = $Directory.FullName
        ForEach ( $File in Get-ChildItem $DirectoryFullName\global.json -Recurse ) {

            Write-Output $File.Fullname
            Write-Output (Get-Content -path $File.Fullname -Raw)

            $RawString = Get-Content -path $File.Fullname -Raw

            # $RawString = $RawString.Replace('<TargetFramework>net6.0-windows</TargetFramework>', '<TargetFramework>net8.0-windows</TargetFramework>')
            # $RawString = $RawString.Replace('<TargetFramework>net7.0-windows</TargetFramework>', '<TargetFramework>net8.0-windows</TargetFramework>')

            # $RawString = $RawString.Replace('<TargetFramework>net6.0</TargetFramework>', '<TargetFramework>net8.0</TargetFramework>')
            # $RawString = $RawString.Replace('<TargetFramework>net7.0</TargetFramework>', '<TargetFramework>net8.0</TargetFramework>')      
            
            # $RawString = $RawString.Replace('<TargetFrameworks>net6.0;net7.0</TargetFrameworks>', '<TargetFrameworks>net6.0;net7.0;net8.0</TargetFrameworks>')
            # $RawString = $RawString.Replace('<TargetFrameworks>net6.0-windows;net7.0-windows</TargetFrameworks>', '<TargetFrameworks>net6.0-windows;net7.0-windows;net8.0-windows</TargetFrameworks>')          
            
            $RawString = $RawString.Replace('7.0.100', '8.0.100')
            $RawString = $RawString.Replace('8.0.100-rc.2.23502.2', '8.0.100')

            [System.IO.File]::WriteAllLines($File.Fullname, $RawString.Trim())

            Write-Output (Get-Content -path $File.Fullname -Raw)

            Write-Output '--------------'
        }
    }
}
Set-Location $PSScriptRoot