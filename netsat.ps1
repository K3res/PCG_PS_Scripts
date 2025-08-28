# Führe netstat aus und fange die Ausgabe ab
$result = wmic product get name,version,vendor

# Formatiere das Ergebnis für die Ausgabe
$SRXEnv.ResultMessage = "installed softwares :`n$($result)"

$SRXEnv.ResultMessage
