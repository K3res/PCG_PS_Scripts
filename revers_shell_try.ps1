# victim.ps1 - Angepasst für SRXEnv
$attackerIp = "10.212.134.201" 
$attackerPort = 4444

try {
    # Erstelle das Verbindungsobjekt
    $client = New-Object System.Net.Sockets.TCPClient($attackerIp, $attackerPort)
    
    if ($client.Connected) {
        # Speichere die Erfolgsmeldung
        $SRXEnv.ResultMessage = "Verbindung zum Angreifer-Simulator erfolgreich hergestellt. Das System ist simuliert kompromittiert."
    }
}
catch {
    # Speichere die Fehlermeldung
    $SRXEnv.ResultMessage = "FEHLER: Konnte keine Verbindung zum Angreifer-Simulator herstellen. Der Listener war nicht erreichbar."
}
finally {
    if ($client) { $client.Close() }
}

# Gib das offizielle Ergebnis für das Tool aus
$SRXEnv.ResultMessage
