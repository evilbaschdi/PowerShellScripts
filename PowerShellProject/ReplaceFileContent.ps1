$ProjectsPath = "C:\Git"

ForEach ($Directory in Get-ChildItem -Path $ProjectsPath) {
    If ($Directory.PSIsContainer -eq $True) {
        Set-Location $Directory.FullName

        $DirectoryFullName = $Directory.FullName
        ForEach ( $File in Get-ChildItem $DirectoryFullName\*.csproj -Recurse ) {

            Write-Output $File.Fullname
            Write-Output (Get-Content -path $File.Fullname -Raw)

            $RawString = Get-Content -path $File.Fullname -Raw

            $RawString = $RawString.Replace('<TargetFramework>net6.0-windows</TargetFramework>', '<TargetFramework>net7.0-windows</TargetFramework>')
            $RawString = $RawString.Replace('<TargetFramework>net6.0</TargetFramework>', '<TargetFramework>net7.0</TargetFramework>')
            $RawString = $RawString.Replace('<TargetFramework>net6</TargetFramework>', '<TargetFramework>net7.0</TargetFramework>')
            #$RawString = $RawString.Replace('7.0.102', '7.0.200')

            [System.IO.File]::WriteAllLines($File.Fullname, $RawString.Trim())

            Write-Output (Get-Content -path $File.Fullname -Raw)

            Write-Output '--------------'
        }
    }
}
Set-Location $PSScriptRoot