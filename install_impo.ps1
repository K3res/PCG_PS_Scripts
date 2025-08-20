#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Sucht nach einem bestimmten Skript auf dem System, analysiert es
    und installiert alle fehlenden Modul-Abhängigkeiten.
#>

# --- KONFIGURATION ---
# Der Name der Skriptdatei, die gesucht werden soll.
$scriptNameToFind = "VirtualMachines.ps1"

# Das Laufwerk, das durchsucht werden soll (z.B. "C:\", "D:\", oder "C:\Users\DeinName").
$searchPath = "C:\"
# --------------------

Write-Host "Suche nach '$scriptNameToFind' im Verzeichnis '$searchPath'. Dies kann einige Minuten dauern..." -ForegroundColor Cyan

# Führe die Suche durch. Fehler wie "Zugriff verweigert" werden ignoriert.
$foundFiles = Get-ChildItem -Path $searchPath -Filter $scriptNameToFind -Recurse -ErrorAction SilentlyContinue

# Auswertung der Suchergebnisse
if ($foundFiles.Count -eq 0) {
    Write-Error "Die Datei '$scriptNameToFind' konnte auf dem Laufwerk '$searchPath' nicht gefunden werden."
    return
}
elseif ($foundFiles.Count -gt 1) {
    Write-Warning "Es wurden mehrere Dateien mit dem Namen '$scriptNameToFind' gefunden. Bitte gib den genauen Pfad an."
    Write-Host "Gefundene Pfade:"
    $foundFiles.FullName | ForEach-Object { Write-Host "- $_" }
    return
}

# --- Wenn genau eine Datei gefunden wurde, geht es hier weiter ---
$scriptPath = $foundFiles.FullName
Write-Host "Datei gefunden: '$scriptPath'" -ForegroundColor Green
Write-Host "Analysiere Skript..." -ForegroundColor Green

# Skript-Inhalt parsen, um alle Befehle zu extrahieren
$ast = [System.Management.Automation.Language.Parser]::ParseFile($scriptPath, [ref]$null, [ref]$null)
$commands = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $true) | ForEach-Object { $_.GetCommandName() } | Sort-Object -Unique

if ($null -eq $commands) {
    Write-Host "Keine Befehle im Skript gefunden."
    return
}

Write-Host "Gefundene Befehle: $($commands.Count)"

# Liste der benötigten Module, die noch installiert werden müssen
$modulesToInstall = [System.Collections.Generic.List[string]]::new()

foreach ($command in $commands) {
    if ($null -ne (Get-Command $command -ErrorAction SilentlyContinue)) {
        continue
    }

    Write-Host "Befehl '$command' nicht lokal gefunden. Suche in der PowerShell Gallery..." -ForegroundColor Yellow
    try {
        $foundModule = (Find-Module -Command $command -Repository PSGallery -ErrorAction Stop).Name
        if ($foundModule -and $modulesToInstall -notcontains $foundModule) {
            Write-Host "Modul '$foundModule' für Befehl '$command' gefunden." -ForegroundColor Cyan
            $modulesToInstall.Add($foundModule)
        }
    }
    catch {
        Write-Warning "Konnte kein Modul für den Befehl '$command' in der PSGallery finden."
    }
}

# Module installieren, falls welche gefunden wurden
if ($modulesToInstall.Count -gt 0) {
    Write-Host "`nFolgende Module werden installiert: $($modulesToInstall -join ', ')" -ForegroundColor Green
    
    foreach ($moduleName in $modulesToInstall) {
        Write-Host "Installiere Modul '$moduleName'..."
        Install-Module -Name $moduleName -Repository PSGallery -Force -AllowClobber -Scope AllUsers
    }
    
    Write-Host "`nAlle benötigten Module wurden installiert." -ForegroundColor Green
}
else {
    Write-Host "`nAlle benötigten Module sind bereits auf dem System vorhanden." -ForegroundColor Green
}
