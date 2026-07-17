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

## Aktionen in definierten Maskenzuständen

Bildschirmaufnahmen und andere Aktionen werden als PowerShell-Codeblöcke an die Eingabefunktion übergeben. Die Funktion führt den Codeblock aus, solange der gewünschte Maskenzustand sichtbar ist, und speichert die Daten anschließend selbst.

```Powershell
New-Behandler `
    -BehNummer '001' `
    -BehVorname 'Anna' `
    -BehName 'Weber' `
    -OnFirstPage {
        param($Context)
        Save-DLPDocumentationWindow -Path '.\Bilder\04-Behandler-anlegen-Seite1.png'
    } `
    -OnSecondPage {
        param($Context)
        Save-DLPDocumentationWindow -Path '.\Bilder\05-Behandler-anlegen-Seite2.png'
    }
```

`New-Behandler` führt nach `OnFirstPage` und `OnSecondPage` jeweils F10 aus. Der fotografierte Behandler bleibt damit dauerhaft gespeichert.

Beim Kunden können mehrere Zustände separat behandelt werden:

```Powershell
New-Kunde `
    -KunNummer '9001' `
    -KunName 'Gemeinschaftspraxis' `
    -OnFirstPage  { Save-DLPDocumentationWindow -Path '.\Bilder\Kunde-Seite1.png' } `
    -OnThirdPage  { Save-DLPDocumentationWindow -Path '.\Bilder\Kunde-Seite3.png' } `
    -OnSecondPage { Save-DLPDocumentationWindow -Path '.\Bilder\Kunde-Seite2.png' }
```

Die Reihenfolge entspricht der Programmlogik: erste Seite, optional über F4 die dritte Seite, anschließend beim Speichern automatisch die zweite Seite.

Die Behandlerauswahl und der ausgefüllte Auftragskopf können in einem vollständig angelegten Auftrag fotografiert werden:

```Powershell
New-Auftrag `
    -AufKunNummer '9001' `
    -AufBehandlerNummer '001' `
    -OnBehandlerSelection {
        Save-DLPDocumentationWindow -Path '.\Bilder\Auftrag-Behandlerauswahl.png'
    } `
    -OnHeader {
        Save-DLPDocumentationWindow -Path '.\Bilder\Auftrag-mit-Behandler.png'
    }
```

Nach `OnHeader` wechselt `New-Auftrag` mit F4 in die Positionserfassung. Der Auftragskopf wird damit übernommen und bleibt nicht nur als ungespeicherte Bildschirmmaske stehen.

Jeder Codeblock erhält optional ein Kontextobjekt:

```Powershell
-OnHeader {
    param($Context)
    Write-Verbose "$($Context.Module): $($Context.State)"
    Write-Verbose "Kunde: $($Context.Data.KundenNummer)"
}
```

## Eingabemasken verlassen

Die Exit-Funktionen `Exit-Kunde`, `Exit-Auftrag` und `Exit-Behandler` unterstützen optional `-Save`:

```Powershell
Exit-Kunde -Save
Exit-Auftrag -Save
Exit-Behandler -Save
```

`-Save` sendet genau einmal F10 statt ESC. Der Parameter darf nur verwendet werden, wenn tatsächlich eine Eingabemaske geöffnet ist. Mehrseitige Neuanlagen sollten über `New-Kunde` beziehungsweise `New-Behandler` abgeschlossen werden, da diese Funktionen alle benötigten Speicherschritte selbst ausführen. In Verwaltungsübersichten ist F10 häufig mit dem Listenmenü belegt; dort wird weiterhin ohne `-Save` beziehungsweise mit der speziellen Verwaltungsfunktion verlassen:

```Powershell
Exit-Kunde
Exit-KundeBehandler
Exit-BehandlerUmsatz
```

Die früheren Schalter `StayOnFirstPage`, `StayOnSecondPage` und `StayInHeader` werden nur noch aus Kompatibilitätsgründen erkannt. Sie dürfen nur zusammen mit dem passenden Codeblock verwendet werden und lassen keine ungespeicherten Daten mehr zurück.
