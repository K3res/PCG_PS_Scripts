# Führe netstat aus und fange die Ausgabe ab
$result = Get-NetIPAddress

# Formatiere das Ergebnis für die Ausgabe
$SRXEnv.ResultMessage = "installed softwares :`n$($result)"

$SRXEnv.ResultMessage
