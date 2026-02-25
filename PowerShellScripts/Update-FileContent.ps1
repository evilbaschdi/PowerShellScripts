$ProjectsPath = "C:\Git"

ForEach ($Directory in Get-ChildItem -Path $ProjectsPath) {
    If ($Directory.PSIsContainer -eq $True) {
        Set-Location $Directory.FullName

        $DirectoryFullName = $Directory.FullName
        ForEach ( $File in Get-ChildItem $DirectoryFullName\*.props -Recurse ) {

            Write-Output $File.Fullname
            Write-Output (Get-Content -path $File.Fullname -Raw)

            $RawString = Get-Content -path $File.Fullname -Raw

            $RawString = $RawString.Replace('<TargetFrameworks>net9.0-windows</TargetFrameworks>', '<TargetFrameworks>net10.0-windows</TargetFrameworks>')
            $RawString = $RawString.Replace('<TargetFrameworks>net9.0</TargetFrameworks>', '<TargetFrameworks>net10.0</TargetFrameworks>')

            [System.IO.File]::WriteAllLines($File.Fullname, $RawString.Trim())

            Write-Output (Get-Content -path $File.Fullname -Raw)

            Write-Output '--------------'
        }

        ForEach ( $File in Get-ChildItem $DirectoryFullName\*.csproj -Recurse ) {

            Write-Output $File.Fullname
            Write-Output (Get-Content -path $File.Fullname -Raw)

            $RawString = Get-Content -path $File.Fullname -Raw

            $RawString = $RawString.Replace('<TargetFrameworks>net9.0-windows</TargetFrameworks>', '<TargetFrameworks>net10.0-windows</TargetFrameworks>')
            $RawString = $RawString.Replace('<TargetFrameworks>net9.0</TargetFrameworks>', '<TargetFrameworks>net10.0</TargetFrameworks>')

            [System.IO.File]::WriteAllLines($File.Fullname, $RawString.Trim())

            Write-Output (Get-Content -path $File.Fullname -Raw)

            Write-Output '--------------'
        }
    }
}
Set-Location $PSScriptRoot
