# Führe netstat aus und fange die Ausgabe ab
$result = Get-CimInstance -ClassName Win32_Product | Select-Object -Property Name, Version, Vendor

# Formatiere das Ergebnis für die Ausgabe
$SRXEnv.ResultMessage = "installed softwares :`n$($result)"

$SRXEnv.ResultMessage
