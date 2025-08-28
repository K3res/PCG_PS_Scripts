# Führe den Befehl aus und fange die Ausgabe ab
$result = whoami.exe /all

# Formatiere das Ergebnis für die Ausgabe
$SRXEnv.ResultMessage = "Ergebnis von 'whoami /all':`n$($result)"

$SRXEnv.ResultMessage
