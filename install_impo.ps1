#Requires -Version 5.1
#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Analysiert ein PowerShell-Skript, um fehlende Modul-Abhängigkeiten zu finden und zu installieren.
.DESCRIPTION
    Dieses Skript liest eine angegebene .ps1-Datei, extrahiert alle verwendeten Befehle,
    sucht nach den dazugehörigen Modulen in der PowerShell Gallery und installiert alle,
    die auf dem lokalen System noch nicht vorhanden sind.
.PARAMETER ScriptPath
    Der vollständige Pfad zur .ps1-Datei, die analysiert werden soll.
.EXAMPLE
    .\Install-RequiredModules.ps1 -ScriptPath "C:\Scripts\VirtualMachines.ps1"
#>
param(
    [Parameter(Mandatory = $true)]
    [string]$ScriptPath
)

# Überprüfen, ob die Skriptdatei existiert
if (-not (Test-Path -Path $ScriptPath -PathType Leaf)) {
    Write-Error "Die angegebene Datei '$ScriptPath' wurde nicht gefunden."
    return
}

Write-Host "Analysiere Skript: '$ScriptPath'..." -ForegroundColor Green

# Skript-Inhalt parsen, um alle Befehle zu extrahieren
$ast = [System.Management.Automation.Language.Parser]::ParseFile($ScriptPath, [ref]$null, [ref]$null)
$commands = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $true) | ForEach-Object { $_.GetCommandName() } | Sort-Object -Unique

if ($null -eq $commands) {
    Write-Host "Keine Befehle im Skript gefunden."
    return
}

Write-Host "Gefundene Befehle: $($commands.Count)"

# Liste der benötigten Module, die noch installiert werden müssen
$modulesToInstall = [System.Collections.Generic.List[string]]::new()

foreach ($command in $commands) {
    # Prüfen, ob der Befehl lokal bereits existiert
    $localCommand = Get-Command $command -ErrorAction SilentlyContinue
    if ($null -ne $localCommand) {
        continue # Befehl ist bereits vorhanden, nächster
    }

    Write-Host "Befehl '$command' nicht lokal gefunden. Suche in der PowerShell Gallery..." -ForegroundColor Yellow
    
    # Wenn nicht lokal vorhanden, online in der PowerShell Gallery suchen
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
