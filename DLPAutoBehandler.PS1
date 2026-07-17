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
        [Switch]$StayOnFirstPage,
        [Switch]$StayOnSecondPage
    )

    If (-Not (Test-DLPBehandlerModulAktiv -IniPath $DlpMainIni)) {
        throw 'Das Behandlermodul ist in der DLP_MAIN.INI nicht aktiviert.'
    }

    If ($StayOnFirstPage -and $StayOnSecondPage) {
        throw 'StayOnFirstPage und StayOnSecondPage können nicht gemeinsam verwendet werden.'
    }

    If (Select-App -App $global:DlpAutoApp) {
        # Startpunkt muss die Behandlerübersicht des gewünschten Kunden sein.
        $ErsteSeite = "{F2}$BehNummer{ENTER}$BehStatus{ENTER}$BehAnrede{ENTER}$BehTitel{ENTER}$BehVorname{ENTER}$BehName{ENTER}$BehName2{ENTER}$BehZusatz{ENTER}$BehStrasse{ENTER}$BehPLZ{ENTER}$BehOrt{ENTER}$BehTelefon1{ENTER}$BehTelefon2{ENTER}$BehFax{ENTER}$BehEMail{ENTER}$BehAnredeFloskel"
        If ($StayOnFirstPage) {
            Send-Key -Keys $ErsteSeite
            Return
        }
        Send-Key -Keys "$ErsteSeite{F10}"

        # Beim Neuanlegen wird die zweite Seite automatisch geöffnet.
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
        If (-Not ($StayOnSecondPage)) {
            Send-Key -Keys "{F10}"
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
