# Suchen Sie nach allen .sln-Dateien unter "C:\Git"
$solutionFiles = Get-ChildItem -Path "C:\Git" -Recurse -Include "*.sln"

# Iterieren Sie durch die gefundenen Dateien
foreach ($file in $solutionFiles) {
    # Holen Sie den Pfad zum Verzeichnis, das die .sln-Datei enthält
    $folderPath = $file.Directory.FullName
    
    Write-Host "Verarbeite das Verzeichnis: $folderPath" -ForegroundColor Green
    
    # Wechseln Sie in das Verzeichnis
    Set-Location -Path $folderPath

    # Führen Sie den dotnet sln migrate-Befehl aus
    Write-Host "  Führe 'dotnet sln migrate' aus..." -ForegroundColor Cyan
    try {
        dotnet sln migrate
    }
    catch {
        Write-Host "  Fehler bei der Ausführung von 'dotnet sln migrate' in $folderPath" -ForegroundColor Red
    }

    # Löschen Sie die .sln-Datei
    Write-Host "  Lösche die alte .sln-Datei..." -ForegroundColor Cyan
    try {
        Remove-Item -Path $file.FullName
    }
    catch {
        Write-Host "  Fehler beim Löschen der Datei $file.FullName" -ForegroundColor Red
    }
    
    Write-Host "----------------------------------------"
}

Write-Host "Skript beendet." -ForegroundColor Green