# Zum Testen, mögliche Szenarien 

# Zuerst müssen benötigte Assembly geladen werden
Initialize-Automation

# Kunde anlegen
Enter-Kunde
New-Kunde
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
Exit-Auftrag

# Material anlegen
Enter-Material
New-Material
Exit-Material
