# 1. Definition der Pfade (Variablen)
$projectFolder = "C:\Git" # Dein Standard-Quellcode-Ordner
$jetBrains = "$env:LOCALAPPDATA\JetBrains"
$nugetPackages = "$env:USERPROFILE\.nuget\packages"

# 2. Prozesse (Dateinamen)
$processes = @("devenv.exe", "code.exe", "dotnet.exe", "msbuild.exe", "rider64.exe", "fsnotifier.exe", "git.exe", "ServiceHub.RoslynCodeAnalysisService.exe")

Write-Host "--- Starte Windows Defender Optimierung für Entwickler ---" -ForegroundColor Cyan

# Ordner-Ausschlüsse hinzufügen
Write-Host "[+] Füge Ordner-Ausschlüsse hinzu..." -ForegroundColor Yellow
Add-MpPreference -ExclusionPath $projectFolder, $jetBrains, $nugetPackages

# Prozess-Ausschlüsse hinzufügen
Write-Host "[+] Füge Prozess-Ausschlüsse hinzu..." -ForegroundColor Yellow
foreach ($proc in $processes) {
    Add-MpPreference -ExclusionProcess $proc
}

Write-Host "--- Fertig! Visual Studio & ReSharper sollten nun flüssiger laufen. ---" -ForegroundColor Green
Write-Host "Hinweis: Du kannst die Liste in 'Windows-Sicherheit' -> 'Viren- und Bedrohungsschutz' -> 'Einstellungen für Viren- und Bedrohungsschutz' -> 'Ausschlüsse' überprüfen."