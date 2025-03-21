$ProjectsPath = "C:\Git"

ForEach ($Directory in Get-ChildItem -Path $ProjectsPath) {
    If ($Directory.PSIsContainer -eq $True) {
        Set-Location $Directory.FullName

        $DirectoryFullName = $Directory.FullName
        ForEach ( $File in Get-ChildItem $DirectoryFullName\*.props -Recurse ) {

            Write-Output $File.Fullname
            Write-Output (Get-Content -path $File.Fullname -Raw)

            $RawString = Get-Content -path $File.Fullname -Raw

            $RawString = $RawString.Replace('<TargetFramework>net8.0-windows</TargetFramework>', '<TargetFramework>net9.0-windows</TargetFramework>')

            [System.IO.File]::WriteAllLines($File.Fullname, $RawString.Trim())

            Write-Output (Get-Content -path $File.Fullname -Raw)

            Write-Output '--------------'
        }
    }
}
Set-Location $PSScriptRoot
