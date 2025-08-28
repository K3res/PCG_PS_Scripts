$resultString = "Verfügbare Laufwerke: $((Get-PSDrive | Where-Object {$_.Free -gt 1} | Select-Object -ExpandProperty Name) -join ', ')"
$resultString
