$remoteIp = "192.168.153.155"
$inboundPort = 1433
$outboundPort = 80
$ruleNamePrefix = "WebApp Server Access"

$results = @()

# --- 2. Eingehende Regel (Inbound) erstellen ---
$inboundRuleName = "$ruleNamePrefix - Inbound"
try {
    New-NetFirewallRule -DisplayName $inboundRuleName -Direction Inbound -Action Allow -Protocol TCP -LocalPort $inboundPort -RemoteAddress $remoteIp -ErrorAction Stop
    $results += "[+] ERFOLG: Eingehende Regel '$inboundRuleName' wurde erstellt."
}
catch {
    $results += "[!] FEHLER bei eingehender Regel: $($_.Exception.Message)"
}

# --- 3. Ausgehende Regel (Outbound) erstellen ---
$outboundRuleName = "$ruleNamePrefix - Outbound"
try {
    New-NetFirewallRule -DisplayName $outboundRuleName -Direction Outbound -Action Allow -Protocol TCP -RemotePort $outboundPort -RemoteAddress $remoteIp -ErrorAction Stop
    $results += "[+] ERFOLG: Ausgehende Regel '$outboundRuleName' wurde erstellt."
}
catch {
    $results += "[!] FEHLER bei ausgehender Regel: $($_.Exception.Message)"
}

# --- 4. Finales Ergebnis zusammenfassen ---
# Füge alle gesammelten Nachrichten zu einem einzigen String zusammen.
$SRXEnv.ResultMessage = $results -join "`n"

# --- Gib das offizielle Ergebnis für das Tool aus ---
$SRXEnv.ResultMessage
