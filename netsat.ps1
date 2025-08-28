# Führe netstat aus und fange die Ausgabe ab
$result = netstat.exe -a

# Formatiere das Ergebnis für die Ausgabe
$SRXEnv.ResultMessage = "Aktive Verbindungen und lauschende Ports (netstat -a):`n$($result)"

$SRXEnv.ResultMessage
