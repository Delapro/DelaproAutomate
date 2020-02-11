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

Wie die Funktionen konkret angewendet werden kann man in der [DLPAutomate.PS1](DLPAutomate.PS1) sehen