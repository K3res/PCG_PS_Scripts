# Definiere das Ziel
$ipAddress = "192.168.1.1" # Ersetze dies mit deiner Ziel-IP
$port = 2222

# Führe den Verbindungstest durch
$connectionTest = Test-NetConnection -ComputerName $ipAddress -Port $port

# Gib eine klare Ergebnisnachricht aus
if ($connectionTest.TcpTestSucceeded) {
    $SRXEnv.ResultMessage = "Verbindung zu $($ipAddress) auf Port $($port) war erfolgreich."
} else {
    $SRXEnv.ResultMessage = "FEHLER: Verbindung zu $($ipAddress) auf Port $($port) ist fehlgeschlagen."
}

$SRXEnv.ResultMessage
