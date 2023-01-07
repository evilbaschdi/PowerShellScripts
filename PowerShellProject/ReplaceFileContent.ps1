$ProjectsPath = "C:\Git"

ForEach ($Directory in Get-ChildItem -Path $ProjectsPath) {
    If ($Directory.PSIsContainer -eq $True) {
        Set-Location $Directory.FullName

        $DirectoryFullName = $Directory.FullName
        ForEach ( $File in Get-ChildItem $DirectoryFullName\global.json -Recurse ) {

            Write-Output $File.Fullname
            Write-Output (Get-Content -path $File.Fullname -Raw)

            $RawString = Get-Content -path $File.Fullname -Raw

            #$RawString = $RawString.Replace('<TargetFramework>net5.0-windows</TargetFramework>', '<TargetFramework>net6.0-windows</TargetFramework>')
            #$RawString = $RawString.Replace('<TargetFramework>net5.0</TargetFramework>', '<TargetFramework>net6.0</TargetFramework>')
            #$RawString = $RawString.Replace('<TargetFramework>net5</TargetFramework>', '<TargetFramework>net6.0</TargetFramework>')
            $RawString = $RawString.Replace('7.0.100', '7.0.101')
            #$RawString = $RawString.Replace('7.0.100-rc.2.22477.23', '7.0.100')

            [System.IO.File]::WriteAllLines($File.Fullname, $RawString.Trim())

            Write-Output (Get-Content -path $File.Fullname -Raw)

            Write-Output '--------------'
        }
    }
}
Set-Location $PSScriptRoot