# Zum Testen, mögliche Szenarien 

# Erweiterungsideen
# mit PSDBF kombinieren, zum Abfragen von Zuständen
# DLP_MAIN.INI auslesen um auf bestimmte Einstellungen reagieren zu können
# TODO: Durchgriffe von AufPos->Jumbos, Kunde->Aufträge, AufPos->Artikel usw.

# Zuerst müssen benötigte Assembly geladen werden
Initialize-Automation
# auf langsamen Rechnern werden die Tastendrücke aufgrund von 
# Timingproblemen nicht immer korrekt verarbeitet, mittels
# dieser Variablen kann man eine kleine Verschnaufpause nach dem
# Selektieren bzw Aktivieren der App sowie nach dem Senden von Tasten
# einbauen
# die folgenden Parameter werden auch von Initialize-Automation automatisch gesetzt:
$global:DlpAutoSelectAppSleep = 100
$global:DlpAutoSendKeySleep = 10
$global:DlpAutoApp = 'Delapro'

$Patienten=@( [PSCustomObject]@{Name='Müller';Vorname='Klaus';XMLAuftragsNr='3-6-9'}
             ,[PSCustomObject]@{Name='Wagner';Vorname='Michael';XMLAuftragsNr='3-6-9'}
             ,[PSCustomObject]@{Name='Lüdenscheidt';Vorname='Gabriele';XMLAuftragsNr='3-6-9'}
             ,[PSCustomObject]@{Name='Sonnenschein';Vorname='Klaus';XMLAuftragsNr='3-6-9'}
             ,[PSCustomObject]@{Name='Sonnenschein';Vorname='Jutta';XMLAuftragsNr='3-6-9'}
            )

# Delapro aufrufen
Start-Process $env:PUBLIC\Desktop\Delapro.lnk
Start-Sleep -Milliseconds 200
Select-App 'Delapro'; Send-Key '{F2}'
Wait-FileAvailable -File 'C:\Delapro\AufBeweg.CDX'
Start-Sleep -Seconds 2

# zum Aufzeichnen von Bildern
Save-ActiveWindow

# Kunde anlegen mit Sprachausgabe
$s= Out-Speech -Text "Kundenverwaltung aufrufen und neuen Kunden anlegen." -Async
Enter-Kunde
New-Kunde
Wait-Speech $s
Exit-Kunde

# Kunde anlegen 
Enter-Kunde
New-Kunde
Exit-Kunde

# Techniker anlegen
Enter-Techniker
New-Techniker
Exit-Techniker

# Auftrag mit Positionen anlegen und zum KV machen
Function New-TestKV {
    [CmdletBinding()]
    Param(
        [System.String]$Patient='Testpatient'
        # $Positionen muss Typfrei sein, oder es muss eine ordentliche Struktur her!
        ,$Positionen=@(@('10', 2),'51','120',@('1620', 2),'9330')
    )

    Enter-Auftrag
    New-Auftrag -AufPatient $Patient
    $ExitAufPosParameter = @{}
    If ($Positionen -is [Array]) {
        If ($Positionen.Length -ge 1) {
          $ExitAufPosParameter = @{RemoveBlankRow=$true}
        }
        foreach ($Position in  $Positionen) {
            If ($Position -is [Array]) {
                $LeisMat = $Position[0]
                $Menge = $Position[1]
            } else {
                $LeisMat = $Position
                $Menge = 1
            }
            New-AufPos -BelBebNr $LeisMat -Menge $Menge
        }
    }
    Exit-AufPos -Save @ExitAufPosParameter
    Out-Auftrag -IgnoreCall -Treiber Ansicht -Formular Kostenvoranschlag
    Start-Sleep -Milliseconds 200
    Wait-AcrobatReader
    Start-Sleep -Seconds 1
    Exit-AcrobatReader
    Start-Sleep -Milliseconds 200
    Exit-Auftrag
}

# Auftrag mit Positionen anlegen und zur Rechnung machen
Function New-TestRechnung {
    [CmdletBinding()]
    Param(
         [System.String]$Patient='Testpatient'
        ,[System.String]$XMLAuftragsnummer='3-6-9'
        # $Positionen muss Typfrei sein, oder es muss eine ordentliche Struktur her!
        ,$Positionen=@(@('10', 2),'51','120',@('1620', 2),'9330')
    )

    Enter-Auftrag
    New-Auftrag -AufPatient $Patient -AufXMLNummer $XMLAuftragsnummer
    If ($Positionen -is [Array]) {
        foreach ($Position in  $Positionen) {
            If ($Position -is [Array]) {
                $LeisMat = $Position[0]
                $Menge = $Position[1]
            } else {
                $LeisMat = $Position
                $Menge = 1
            }
            New-AufPos -BelBebNr $LeisMat -Menge $Menge
        }
    }
    Exit-AufPos -Save
    Out-Auftrag -IgnoreCall -Treiber Ansicht -Formular Rechnung
    Start-Sleep -Milliseconds 200
    Wait-AcrobatReader
    Start-Sleep -Seconds 1
    Exit-AcrobatReader
    Start-Sleep -Milliseconds 200
    # XML-Datei-Export überspringen
    Select-App 'Delapro'; Send-Key '{ESC}'
    Start-Sleep -Milliseconds 200
    Exit-Auftrag
}

# mehrere KVs anlegen
$Patienten | % {New-TestKV -Patient "$($_.Name), $($_.Vorname)"}

# mehrere Rechnungen anlegen
$Patienten | % {New-TestRechnung -Patient "$($_.Name), $($_.Vorname)" -XMLAuftragsnummer $_.XMLAuftragsnr}

# Material anlegen
Enter-Artikel
New-Material
Exit-Artikel

# Jumbo anlegen
Enter-Jumbo
New-Jumbo
Exit-Jumbo

# darauf achten, dass DLP_TIME läuft!
# Tageszeitmodell anlegen
Enter-Tageszeitmodell
New-Tageszeitmodell -Nummer 1 -Beschreibung "TZM 1" -Zeitart Gleitzeit -Sollzeit '8:00'
Exit-Tageszeitmodell
# WochenZeitmodell anlegen
New-Wochenzeitmodell -Nummer 1 -Beschreibung "WZM 1" -Montag 1 -Dienstag 1 -Mittwoch 1 -Donnerstag 1 -Freitag 1
Enter-Wochenzeitmodell

Exit-Wochenzeitmodell

# Sonstiges
# Windows-Taste drücken, um Startmenü zu öffnen
Send-Key -SpecialKey Win


# Möglichkeit DBU32 Fernzusteuern
# wichtig: DBU32 hat keinen eigenen Fenstertitel! Deshalb wird hier das Powershellfenster verwendet
# hier als Beispiel soll ein Replace stattfinden, betreffende DBF muss schon in DBU32 geöffnet sein
# das Replace-Menü wird mittels F6 geöffnet, da aber r auch Run auslösen könnte wird zunächst mit
# mehreren "Pfeil nach oben"-Tasten den ersten Menüpunkt angefahren um von da aus gezielt Replace
# mittels r auswählen zu können
# in diesem Beispiel muss AUFTRAG.DBF bereits Selektiert sein!
Select-App -App 'Windows Powershell'
Send-Key -Keys '{F6}{UP}{UP}{UP}{UP}{UP}{UP}r{Enter}'
$SelectField = 'g'  # erstes Feld mit G = Gedrucktdatumfeld bei AUFTRAG.DBF
$ReplaceWith = 'Datum' # 126 Zeichen max!
$ReplaceFor = 'AuftragArt == "K" .AND. Gedruckt == CTOD{(}"26.02.2020"{)}' # ( und ) sind Sonderzeichen!
Send-Key -Keys "$SelectField"
Start-Sleep -Milliseconds 200   # Verschnaufpausen müssen sein, sonst verschluckt sich DBU32
Send-Key -Keys "{ENTER}{ENTER}"
Start-Sleep -Milliseconds 200
Send-Key -Keys "$ReplaceWith"
Start-Sleep -Milliseconds 200
Send-Key -Keys "{DOWN}{ENTER}$ReplaceFor"

# zum Einblenden von Tastendrücken bei Aufnahmen kann man Carnac verwenden
# https://github.com/Code52/carnac
# alternative KeyPress OSD
# unter Mac MousePose
# siehe auch: https://superuser.com/questions/104421/windows-utility-to-render-which-key-i-am-pressing-on-screen
