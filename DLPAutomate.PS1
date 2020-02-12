# Zum Testen, mögliche Szenarien 

# Erweiterungsideen
# mit PSDBF kombinieren, zum Abfragen von Zuständen
# DLP_MAIN.INI auslesen um auf bestimmte Einstellungen reagieren zu können

# Zuerst müssen benötigte Assembly geladen werden
Initialize-Automation

# zum Aufzeichnen von Bildern
Save-ActiveWindow

# Kunde anlegen
$s= Out-Speech -Text "Kundenverwaltung aufrufen und neuen Kunden anlegen." -Async
Enter-Kunde
New-Kunde
Wait-Speech $s
Exit-Kunde

# Techniker anlegen
Enter-Techniker
New-Techniker
Exit-Techniker

# Auftrag mit Positionen anlegen
Enter-Auftrag
New-Auftrag
New-AufPos -BelBebNr 10
New-AufPos -BelBebNr 51
New-AufPos -BelBebNr 120
New-AufPos -BelBebNr 1620
New-AufPos -BelBebNr 9330
Exit-AufPos -Save
Out-Auftrag -IgnoreCall -Treiber Ansicht -Formular Kostenvoranschlag
Start-Sleep -Milliseconds 200
Exit-AcrobatReader
Start-Sleep -Milliseconds 200
Exit-Auftrag

# Material anlegen
Enter-Material
New-Material
Exit-Material
