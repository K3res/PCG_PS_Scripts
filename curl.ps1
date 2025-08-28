$url = 'http://10.212.134.201:2222/'

try {
    # Versuche, die Webseite abzurufen.
    $response = Invoke-WebRequest -Uri $url -UseBasicParsing
    
    # Bei Erfolg wird die Erfolgsmeldung in der Variable gespeichert.
    $SRXEnv.ResultMessage = "[+] ERFOLG! Auf $($url) zugegriffen. Status: $($response.StatusCode) ($($response.StatusDescription))"
}
catch {
    # Bei einem Fehler wird die Fehlermeldung in der Variable gespeichert.
    $SRXEnv.ResultMessage = "[!] FEHLER beim Zugriff auf $($url): $($_.Exception.Message)"
}

# Gib die finale Ergebnisnachricht für das Tool aus.
$SRXEnv.ResultMessage
