# DelaproAutomate

Powershell-Skripte um Delapro Integrationstests oder Erklärvideos erstellen zu können.

Für die Anwendung müssen die [DelaproInstall-Skripte](https://github.com/Delapro/DelaproInstall) vorher ausgeführt werden.

Hat man die normalen DelaproInstall-Skripte geladen, kann man mit dem Befehl 

```Powershell
# Dot-Sourcing damit die Funktionen zur Verfügung stehen!
. Invoke-DelaproAutomateDownloadAndInit
```

die Automatisierungsskripte automatisch nachladen. Danach stehen einem die Funktionen zur Verfügung.

> **Hinweis zu älteren Versionen**
>
> Die Scripts werden ausschließlich unter Windows 10 1909 und neuer getestet.

Wie die Funktionen konkret angewendet werden kann man in der [DLPAutomate.PS1](DLPAutomate.PS1) sehen.

# Videotools
Der Bereich Videotools enthält Programme für die Videobearbeitung.

Installiert das Videoschnittprogramm OpenShot:
```Powershell
Install-OpenShot
```

# Behandlerautomatisierung

Der Schalter für die Behandlererweiterung kann direkt aus der `DLP_MAIN.INI` geprüft werden:

```Powershell
Test-DLPBehandlerModulAktiv
```

Standardmäßig wird `C:\Delapro\DLP_MAIN.INI` gelesen. Ein anderer Pfad kann über `-IniPath` oder `$global:DlpAutoMainIni` vorgegeben werden.

Behandler für den aktuell markierten Kunden anlegen:

```Powershell
Enter-KundeBehandler
New-Behandler -BehNummer '001' -BehVorname 'Anna' -BehName 'Weber'
Exit-KundeBehandler
```

Auftrag mit oder ohne Behandler anlegen:

```Powershell
New-Auftrag -AufKunNummer '9001' -AufBehandlerNummer '001'
New-Auftrag -AufKunNummer '9001' -AufBehandlerNummer ''
```

Ist das Behandlermodul nicht aktiv, bedient `New-Auftrag` nur das Kundennummernfeld. Ist es aktiv, wird zusätzlich das Behandlerfeld ausgefüllt oder bewusst leer bestätigt.

Für Bildschirmaufnahmen kann die Eingabe vor dem Speichern angehalten werden:

```Powershell
New-Behandler -BehNummer '001' -BehVorname 'Anna' -BehName 'Weber' -StayOnFirstPage
Save-DLPDocumentationWindow -Path '.\Bilder\03-Behandler-anlegen-Seite1.png'

Show-NeuerAuftragBehandlerAuswahl -AufKunNummer '9001'
Save-DLPDocumentationWindow -Path '.\Bilder\05-Auftrag-Behandlerauswahl.png'
```

Mit `-StayInHeader` bleibt `New-Auftrag` im Auftragskopf und öffnet noch nicht die Positionserfassung.
