# First, get the list of drives as a string
$driveString = (Get-PSDrive | Where-Object {$_.Free -gt 1} | Select-Object -ExpandProperty Name) -join ', '

# Now, assign this string to the special variable for the tool
$SRXEnv.ResultMessage = "Verfügbare Laufwerke: $driveString"

# You can still output it for testing in a normal console
$SRXEnv.ResultMessage
