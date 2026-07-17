# DLPAutoKunde.PS1

Function New-Kunde {
    [CmdletBinding()]
    Param(
        [String]$KunNummer,
        [String]$KunAnrede='Zahnarzt',
        [String]$KunTitel='Dr.',
        [String]$KunVorname='Vorname',
        [String]$KunName='Tester'    
    )
    
    If (Select-App -App $global:DlpAutoApp) {
        $KundenNummerEingabe = "{ENTER}"
        If ($PSBoundParameters.ContainsKey('KunNummer')) {
            $KundenNummerEingabe = "$KunNummer{ENTER}"
        }

        Send-Key -Keys "{F2}$KundenNummerEingabe{ENTER}$KunAnrede{ENTER}$KunTitel{ENTER}$KunVorname{ENTER}$KunName{PGDN}"
        # zweite Seite
        Send-Key -Keys "{PGDN}"
        # dritte Seite
        Send-Key -Keys "{PGDN}"
    }
}

Function Enter-KundeBehandler {
    [CmdletBinding()]
    Param(
        [String]$DlpMainIni=$global:DlpAutoMainIni
    )

    If (-Not (Test-DLPBehandlerModulAktiv -IniPath $DlpMainIni)) {
        throw 'Das Behandlermodul ist in der DLP_MAIN.INI nicht aktiviert.'
    }

    If (Select-App -App $global:DlpAutoApp) {
        # Startpunkt ist die Kundenübersicht mit dem gewünschten Kunden.
        # F4 öffnet die Kundendaten, F8 die Behandlerverwaltung.
        Send-Key -Keys "{F4}"
        Start-Sleep -Milliseconds 100
        Send-Key -Keys "{F8}"
    }
}

Function Exit-KundeBehandler {

    If (Select-App -App $global:DlpAutoApp) {
        # Zurück aus der Behandlerverwaltung in die Kundendaten.
        Send-Key -Keys "{ESC}"
    }
}

Function Enter-Kunde {

    If (Select-App -App $global:DlpAutoApp) {
        # Startpunkt muss das Hauptmenü sein!
        Send-Key -Keys "{F2}"
    }
}

Function Exit-Kunde {

    If (Select-App -App $global:DlpAutoApp) {
        Send-Key -Keys "{ESC}"
    }
}
