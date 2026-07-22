# DelaproAutomate

Powershell-Skripte um Delapro Integrationstests oder Erklärvideos erstellen zu können.

Für die Anwendung müssen die [DelaproInstall-Skripte](https://github.com/Delapro/DelaproInstall) vorher ausgeführt werden.

Hat man die normalen DelaproInstall-Skripte geladen, kann man mit dem Befehl 

```Powershell
# Dot-Sourcing damit die Funktionen zur Verfügung stehen!
. Invoke-DelaproAutomateDownloadAndInit
```

die Automatisierungsskripte automatisch nachladen. Danach stehen einem die Funktionen zur Verfügung.

Fügt man neue Automationsskripte hinzu müssen diese in <Code>AutoLoadFiles.json</Code> eingetragen werden, damit sie bei <Code>Invoke-DelaproAutomateDownloadAndInit</Code> automatisch geladen werden.

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
New-Auftrag -AufKunNummer '001' -AufBehandlerNummer '001'
New-Auftrag -AufKunNummer '001' -AufBehandlerNummer ''
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
    -KunNummer '001' `
    -KunName 'Gemeinschaftspraxis' `
    -OnFirstPage  { Save-DLPDocumentationWindow -Path '.\Bilder\Kunde-Seite1.png' } `
    -OnThirdPage  { Save-DLPDocumentationWindow -Path '.\Bilder\Kunde-Seite3.png' } `
    -OnSecondPage { Save-DLPDocumentationWindow -Path '.\Bilder\Kunde-Seite2.png' }
```

Die Reihenfolge entspricht der Programmlogik: erste Seite, optional über F4 die dritte Seite, anschließend beim Speichern automatisch die zweite Seite.

Die Behandlerauswahl und der ausgefüllte Auftragskopf können in einem vollständig angelegten Auftrag fotografiert werden:

```Powershell
New-Auftrag `
    -AufKunNummer '001' `
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

## Fenster- und Clientbereich aufnehmen

`Save-ActiveWindow` behält aus Kompatibilitätsgründen das bisherige Verhalten bei und speichert ohne weitere Angabe das komplette Fenster mit Windows-Rahmen:

```Powershell
Save-ActiveWindow -Path '.\Bilder\Delapro-mit-Rahmen.png'
```

Nur der eigentliche Delapro-Inhalt wird mit `-CaptureArea Client` gespeichert:

```Powershell
Save-ActiveWindow `
    -Path '.\Bilder\Delapro-Client.png' `
    -CaptureArea Client
```

`Save-DLPDocumentationWindow` verwendet für Handbuchbilder standardmäßig den Clientbereich. Der Rahmen kann ausdrücklich zugeschaltet werden:

```Powershell
Save-DLPDocumentationWindow -Path '.\Bilder\Maske.png'
Save-DLPDocumentationWindow -Path '.\Bilder\Maske-mit-Rahmen.png' -CaptureArea Window
```

Die Aufnahme wird nicht mehr über `Alt+Druck` und die Zwischenablage erzeugt. Die Funktionen ermitteln den tatsächlichen Fenster- beziehungsweise Clientbereich und kopieren diesen sichtbaren Bildschirmbereich direkt in eine PNG-Datei.

`Copy-Screen` speichert einen frei gewählten Bildschirmbereich. `Width` und `Height` sind dabei echte Breiten- und Höhenangaben:

```Powershell
Copy-Screen -X 100 -Y 100 -Width 800 -Height 500 -Path '.\Bilder\Ausschnitt.png'
```

Für Koordinaten relativ zum Delapro-Inhalt steht `Copy-DLPClientArea` zur Verfügung:

```Powershell
Copy-DLPClientArea -X 20 -Y 40 -Width 500 -Height 260 -Path '.\Bilder\Maskenausschnitt.png'
```

## Mauspositionen im TUI-Raster

Absolute Bildschirmkoordinaten bleiben mit `Set-MousePosition` möglich, sind aber von Fensterposition, Auflösung und Skalierung abhängig. Für Delapro sollte deshalb nach öglichkeit mit dem Clientbereich oder einem festen TUI-Raster gearbeitet werden.

Die Standardwerte werden bei `Initialize-Automation` gesetzt:

```Powershell
$global:DlpAutoTuiRows = 25
$global:DlpAutoTuiColumns = 80
```

Eine 1-basierte TUI-Position kann damit unabhängig von Fenstergröße und Bildschirmauflösung angesprochen werden:

```Powershell
Set-DLPTuiMousePosition -Row 5 -Column 30
Invoke-DLPTuiClick -Row 5 -Column 30
```

Die aktuelle Zellbreite und -höhe wird aus dem tatsächlichen Clientbereich berechnet. Gibt es innerhalb des Clientbereichs zusätzliche Ränder, können diese als Padding angegeben werden:

```Powershell
Invoke-DLPTuiClick `
    -Row 5 `
    -Column 30 `
    -PaddingLeft 4 `
    -PaddingTop 3 `
    -PaddingRight 4 `
    -PaddingBottom 3
```

Auch Bildausschnitte können durch TUI-Zeilen und -Spalten beschrieben werden:

```Powershell
Copy-DLPTuiArea `
    -StartRow 3 `
    -StartColumn 10 `
    -EndRow 18 `
    -EndColumn 70 `
    -Path '.\Bilder\Tui-Ausschnitt.png'
```

Tastatursteuerung bleibt für die eigentliche Delapro-Bedienung der bevorzugte Weg. Mausfunktionen sind nur dann zuverlässig, wenn das angegebene Zeilen-/Spaltenraster tatsächlich dem dargestellten TUI-Raster entspricht und Delapro an der betreffenden Stelle Mausklicks verarbeitet.

## Automatisierte Tests

Die grundlegenden PowerShell-Tests laufen bei Pushes und Pull Requests auf Windows Server 2022 und Windows Server 2025 sowie unter Windows PowerShell 5.1 und PowerShell 7. Geprüft werden unter anderem Syntax, das Laden der Funktionsdateien, die INI-Auswertung, Masken-Codeblöcke und die erzeugten Tastensequenzen.

Der Workflow **Windows UI Tests** wird manuell gestartet. Er erzeugt ein Testfenster und prüft die Bildschirmaufnahme des vollständigen Fensters, des Clientbereichs und eines Clientausschnitts. Die erzeugten PNG-Dateien werden als Workflow-Artefakt gespeichert.

Ein zusätzlicher UI-Test auf einem Windows-10-/Windows-11-Client kann über einen interaktiv gestarteten Self-hosted Runner mit dem benutzerdefinierten Label `dlp-ui-client` aktiviert werden. Dazu ist die Repository-Variable `DLP_RUN_CLIENT_UI_TESTS` auf `true` zu setzen.
