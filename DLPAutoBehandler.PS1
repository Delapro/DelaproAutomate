# DLPAutoBehandler.PS1

Function New-Behandler {
    [CmdletBinding()]
    Param(
        [String]$BehNummer='1',
        [Int]$BehStatus=0,
        [String]$BehAnrede='Zahnarzt',
        [String]$BehTitel='Dr.',
        [String]$BehVorname='Vorname',
        [String]$BehName='Testbehandler',
        [String]$BehName2,
        [String]$BehZusatz,
        [String]$BehStrasse,
        [String]$BehPLZ,
        [String]$BehOrt,
        [String]$BehTelefon1,
        [String]$BehTelefon2,
        [String]$BehFax,
        [String]$BehEMail,
        [String]$BehAnredeFloskel,
        [Nullable[DateTime]]$BehGeburtsdatum,
        [Nullable[DateTime]]$BehAufnahmedatum,
        [String]$BehPreislisteKasse,
        [String]$BehPreislistePrivat,
        [AllowEmptyString()]
        [ValidateSet('', 'J', 'N', '1', '2', '3', '4')]
        [String]$BehAutoPPass='',
        [String]$DlpMainIni=$global:DlpAutoMainIni,
        [ScriptBlock]$OnFirstPage,
        [ScriptBlock]$OnSecondPage,
        [ScriptBlock]$OnSaved,
        [Switch]$StayOnFirstPage,
        [Switch]$StayOnSecondPage
    )

    If (-Not (Test-DLPBehandlerModulAktiv -IniPath $DlpMainIni)) {
        throw 'Das Behandlermodul ist in der DLP_MAIN.INI nicht aktiviert.'
    }

    If ($StayOnFirstPage -and (-Not ($OnFirstPage))) {
        throw 'StayOnFirstPage ist nur noch zusammen mit OnFirstPage zulässig. Der Codeblock wird ausgeführt und der Behandler danach mit F10 gespeichert.'
    }
    If ($StayOnSecondPage -and (-Not ($OnSecondPage))) {
        throw 'StayOnSecondPage ist nur noch zusammen mit OnSecondPage zulässig. Der Codeblock wird ausgeführt und der Behandler danach mit F10 gespeichert.'
    }
    If ($StayOnFirstPage -or $StayOnSecondPage) {
        Write-Warning 'StayOnFirstPage/StayOnSecondPage sind veraltet. Verwenden Sie direkt OnFirstPage bzw. OnSecondPage.'
    }

    If (Select-App -App $global:DlpAutoApp) {
        # Startpunkt muss die Behandlerübersicht des gewünschten Kunden sein.
        $ErsteSeite = "{F2}$BehNummer{ENTER}$BehStatus{ENTER}$BehAnrede{ENTER}$BehTitel{ENTER}$BehVorname{ENTER}$BehName{ENTER}$BehName2{ENTER}$BehZusatz{ENTER}$BehStrasse{ENTER}$BehPLZ{ENTER}$BehOrt{ENTER}$BehTelefon1{ENTER}$BehTelefon2{ENTER}$BehFax{ENTER}$BehEMail{ENTER}$BehAnredeFloskel"
        Send-Key -Keys $ErsteSeite

        Invoke-DLPStateAction -Action $OnFirstPage -Module 'Behandler' -State 'FirstPage' -Data @{
            BehandlerNummer = $BehNummer
            Name = $BehName
            Vorname = $BehVorname
        }

        # F10 speichert die erste Seite. Beim Neuanlegen wird anschließend
        # automatisch die zweite Seite geöffnet.
        Send-Key -Keys "{F10}"
        Start-Sleep -Milliseconds 100

        If ($BehGeburtsdatum.HasValue) {
            Send-Key -Keys "$($BehGeburtsdatum.Value.ToShortDateString())"
        }
        Send-Key -Keys "{ENTER}"

        If ($BehAufnahmedatum.HasValue) {
            Send-Key -Keys "$($BehAufnahmedatum.Value.ToShortDateString())"
        }
        Send-Key -Keys "{ENTER}"

        If ($BehPreislisteKasse) {
            Send-Key -Keys "$BehPreislisteKasse"
        }
        Send-Key -Keys "{ENTER}"

        If ($BehPreislistePrivat) {
            Send-Key -Keys "$BehPreislistePrivat"
        }
        Send-Key -Keys "{ENTER}"

        If ($BehAutoPPass) {
            Send-Key -Keys "$BehAutoPPass"
        }

        Invoke-DLPStateAction -Action $OnSecondPage -Module 'Behandler' -State 'SecondPage' -Data @{
            BehandlerNummer = $BehNummer
            Name = $BehName
            Vorname = $BehVorname
        }

        # Erst nach dem Codeblock speichern. So zeigt ein Bildschirmabdruck
        # den ausgefüllten Zustand, der anschließend auch dauerhaft vorhanden ist.
        Send-Key -Keys "{F10}"
        Start-Sleep -Milliseconds 100

        Invoke-DLPStateAction -Action $OnSaved -Module 'Behandler' -State 'Saved' -Data @{
            BehandlerNummer = $BehNummer
            Name = $BehName
            Vorname = $BehVorname
        }
    }
}

Function Select-Behandler {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [String]$Suchbegriff
    )

    If (Select-App -App $global:DlpAutoApp) {
        # In der Behandlerübersicht kann inkrementell nach Nummer oder Name
        # gesucht werden.
        Send-Key -Keys "$Suchbegriff"
    }
}

Function Edit-Behandler {

    If (Select-App -App $global:DlpAutoApp) {
        # Der gewünschte Behandler muss in der Übersicht markiert sein.
        Send-Key -Keys "{F4}"
    }
}

Function Show-BehandlerUmsatz {
    [CmdletBinding()]
    Param(
        [String]$DlpMainIni=$global:DlpAutoMainIni
    )

    If (-Not (Test-DLPBehandlerModulAktiv -IniPath $DlpMainIni)) {
        throw 'Das Behandlermodul ist in der DLP_MAIN.INI nicht aktiviert.'
    }

    If (Select-App -App $global:DlpAutoApp) {
        # Startpunkt muss die Behandlerübersicht mit markiertem Behandler sein.
        Send-Key -Keys "{F9}"
    }
}

Function Set-BehandlerUmsatzJahr {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [ValidateSet('Vorjahr', 'Folgejahr')]
        [String]$Richtung,
        [ValidateRange(1, 100)]
        [Int]$Anzahl=1
    )

    If (Select-App -App $global:DlpAutoApp) {
        $Taste = If ($Richtung -eq 'Vorjahr') {'{PGUP}'} else {'{PGDN}'}
        1..$Anzahl | ForEach-Object {Send-Key -Keys $Taste}
    }
}

Function Exit-BehandlerUmsatz {

    If (Select-App -App $global:DlpAutoApp) {
        Send-Key -Keys "{ESC}"
    }
}

Function Exit-Behandler {
    [CmdletBinding()]
    Param(
        [Switch]$Save
    )

    # Nur für die Behandler-Eingabemaske verwenden. In der Übersicht ist
    # F10 mit dem Listenmenü belegt.
    Exit-DLPInputMask -Save:$Save
}
