# DLPAutoKunde.PS1

Function New-Kunde {
    [CmdletBinding()]
    Param(
        [String]$KunNummer,
        [String]$KunAnrede='Zahnarzt',
        [String]$KunTitel='Dr.',
        [String]$KunVorname='Vorname',
        [String]$KunName='Tester',
        [ScriptBlock]$OnFirstPage,
        [ScriptBlock]$OnSecondPage,
        [ScriptBlock]$OnThirdPage,
        [ScriptBlock]$OnSaved
    )
    
    If (Select-App -App $global:DlpAutoApp) {
        $KundenNummerEingabe = "{ENTER}"
        If ($PSBoundParameters.ContainsKey('KunNummer')) {
            $KundenNummerEingabe = "$KunNummer{ENTER}"
        }

        # Vorhandene Tastensequenz zum Durchlaufen der ersten Kundenseite.
        Send-Key -Keys "{F2}$KundenNummerEingabe{ENTER}$KunAnrede{ENTER}$KunTitel{ENTER}$KunVorname{ENTER}$KunName"
        If ($OnSecondPage) {
            Invoke-DLPStateAction -Action $OnFirstPage -Module 'Kunde' -State 'FirstPage' -Data @{
                KundenNummer = $KunNummer
                Name = $KunName
                Vorname = $KunVorname
            }
        }
        Send-Key -Keys "{PGDN}"
        Start-Sleep -Milliseconds 100

        If ($OnSecondPage) {
            Invoke-DLPStateAction -Action $OnSecondPage -Module 'Kunde' -State 'SecondPage' -Data @{
                KundenNummer = $KunNummer
                Name = $KunName
                Vorname = $KunVorname
            }
        }
        Send-Key -Keys "{PGDN}"
        Start-Sleep -Milliseconds 100

        If ($OnThirdPage) {
            Invoke-DLPStateAction -Action $OnThirdPage -Module 'Kunde' -State 'ThirdPage' -Data @{
                KundenNummer = $KunNummer
                Name = $KunName
                Vorname = $KunVorname
            }
        }
        Send-Key -Keys "{F10}"
        # Die zweite Seite abschließen, damit der Kunde dauerhaft angelegt ist.
        Send-Key -Keys "{F10}"
        Start-Sleep -Milliseconds 100
        Send-Key -Keys "{F10}"
        Start-Sleep -Milliseconds 100

        If ($OnSaved) {
            Invoke-DLPStateAction -Action $OnSaved -Module 'Kunde' -State 'Saved' -Data @{
                KundenNummer = $KunNummer
                Name = $KunName
                Vorname = $KunVorname
            }
        }

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
        # Hier darf F10 nicht verwendet werden, da es in der Verwaltung
        # das Listenmenü öffnet.
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
    [CmdletBinding()]
    Param(
        [Switch]$Save
    )

    # In der Kundenübersicht öffnet F10 das Listenmenü.
    Exit-DLPInputMask -Save:$Save
}
