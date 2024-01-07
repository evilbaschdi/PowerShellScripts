Param([string]$ProjectsPath = 'C:\Git')

ForEach ($Directory in Get-ChildItem -Path $ProjectsPath) {
    If ($Directory.PSIsContainer -eq $True) {
        Set-Location $Directory.FullName
        If (Test-Path .\.git) {
            $GitDiff = git diff HEAD
            If ($GitDiff -inotlike "") {
                Write-Output $Directory.FullName
                git add -A
                git commit -m "Updated core packages"
            }
        }
    }
}

Set-Location $PSScriptRoot
Write-Output
Write-Output -NoNewLine "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")