#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Sucht nach einem bestimmten Skript, installiert fehlende Modul-Abhängigkeiten
    und führt am Ende einen Ping-Test durch.
#>

# --- KONFIGURATION ---
$scriptNameToFind = "VirtualMachines.ps1"
$searchPath = "C:\"
# --------------------

Write-Host "Suche nach '$scriptNameToFind' im Verzeichnis '$searchPath'. Dies kann einige Minuten dauern..." -ForegroundColor Cyan

$foundFiles = Get-ChildItem -Path $searchPath -Filter $scriptNameToFind -Recurse -ErrorAction SilentlyContinue

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

$scriptPath = $foundFiles.FullName
Write-Host "Datei gefunden: '$scriptPath'" -ForegroundColor Green
Write-Host "Analysiere Skript..." -ForegroundColor Green

$ast = [System.Management.Automation.Language.Parser]::ParseFile($scriptPath, [ref]$null, [ref]$null)
$commands = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $true) | ForEach-Object { $_.GetCommandName() } | Sort-Object -Unique

if ($null -eq $commands) {
    Write-Host "Keine Befehle im Skript gefunden."
} else {
    Write-Host "Gefundene Befehle: $($commands.Count)"
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

    if ($modulesToInstall.Count -gt 0) {
        Write-Host "`nFolgende Module werden installiert: $($modulesToInstall -join ', ')" -ForegroundColor Green
        foreach ($moduleName in $modulesToInstall) {
            Write-Host "Installiere Modul '$moduleName'..."
            Install-Module -Name $moduleName -Repository PSGallery -Force -AllowClobber -Scope AllUsers
        }
        Write-Host "`nAlle benötigten Module wurden installiert." -ForegroundColor Green
    } else {
        Write-Host "`nAlle benötigten Module sind bereits auf dem System vorhanden." -ForegroundColor Green
    }
}

# --- NEU HINZUGEFÜGT: PING-TEST AM ENDE ---
Write-Host "`nFühre abschließenden Ping-Test zu 10.212.134.200 aus..." -ForegroundColor Magenta

$pingSuccess = Test-Connection -ComputerName 10.212.134.200 -Quiet -Count 2 -ErrorAction SilentlyContinue

if ($pingSuccess) {
    Write-Host "Ping erfolgreich! Der Server ist erreichbar." -ForegroundColor Green
} else {
    Write-Host "Ping fehlgeschlagen. Der Server konnte nicht erreicht werden." -ForegroundColor Red
}
