# DLPAutoAuftrag.PS1

Function New-Auftrag {
    [CmdletBinding()]
    Param(
        [String]$AufXMLNummer='3-6-9',
        [String]$AufKunNummer='1',
        [AllowEmptyString()]
        [String]$AufBehandlerNummer='',
        [String]$DlpMainIni=$global:DlpAutoMainIni,
        [DateTime]$AufDatum=(Get-Date),
        [String]$AufPatient='Testpatient',
        [String]$AufKrankenkasse='Privat',
        [String]$AufZahnfarbe='A3',
        [String]$AufBeleg='Beleg',
        [String]$AufArtDerArbeit='Reparatur',
        [Switch]$StayInHeader
    )
    
    If (Select-App -App $global:DlpAutoApp) {
        $AuftragKopf = "{F2}$AufXMLNummer{ENTER}$($AufDatum.ToShortDateString()){ENTER}$AufKunNummer{ENTER}"

        # Bei aktivem Behandlermodul folgt im Auftragskopf direkt nach der
        # Kundennummer das Behandlerfeld. Eine leere Zeichenfolge lässt das
        # Feld bewusst leer.
        If (Test-DLPBehandlerModulAktiv -IniPath $DlpMainIni) {
            $AuftragKopf += "$AufBehandlerNummer{ENTER}"
        } elseif ($AufBehandlerNummer) {
            Write-Verbose 'Behandlernummer wird ignoriert, da das Behandlermodul nicht aktiv ist.'
        }

        $AuftragKopf += "{ENTER}{ENTER}{ENTER}{ENTER}$AufPatient{ENTER}$AufKrankenkasse{ENTER}$AufZahnfarbe{ENTER}$AufBeleg{ENTER}{ENTER}$AufArtDerArbeit"
        If (-Not ($StayInHeader)) {
            $AuftragKopf += "{F4}"
        }
        Send-Key -Keys $AuftragKopf
    }
}

Function Show-NeuerAuftragBehandlerAuswahl {
    [CmdletBinding()]
    Param(
        [String]$AufXMLNummer='3-6-9',
        [String]$AufKunNummer='1',
        [DateTime]$AufDatum=(Get-Date),
        [String]$DlpMainIni=$global:DlpAutoMainIni
    )

    If (-Not (Test-DLPBehandlerModulAktiv -IniPath $DlpMainIni)) {
        throw 'Das Behandlermodul ist in der DLP_MAIN.INI nicht aktiviert.'
    }

    If (Select-App -App $global:DlpAutoApp) {
        # Startpunkt ist die Auftragsübersicht. Nach Kundennummer und Datum
        # bleibt die Behandlerauswahl für einen Screenshot geöffnet.
        Send-Key -Keys "{F2}$AufXMLNummer{ENTER}$($AufDatum.ToShortDateString()){ENTER}$AufKunNummer{ENTER}{F2}"
    }
}

Function Show-AuftragBehandlerAuswahl {
    [CmdletBinding()]
    Param(
        [String]$DlpMainIni=$global:DlpAutoMainIni
    )

    If (-Not (Test-DLPBehandlerModulAktiv -IniPath $DlpMainIni)) {
        throw 'Das Behandlermodul ist in der DLP_MAIN.INI nicht aktiviert.'
    }

    If (Select-App -App $global:DlpAutoApp) {
        # Startpunkt muss das Behandlerfeld im Auftragskopf sein!
        Send-Key -Keys "{F2}"
    }
}

Function Enter-Auftrag {

    If (Select-App -App $global:DlpAutoApp) {
        # Startpunkt muss das Hauptmenü sein!
        Send-Key -Keys "{F3}"
    }
}

Function Exit-Auftrag {

    If (Select-App -App $global:DlpAutoApp) {
        Send-Key -Keys "{ESC}"
    }
}

Function Out-Auftrag {
    [CmdletBinding()]
    Param(
        [Switch]$IgnoreCall,
        [Validateset('Win', 'Ansicht', 'E-Mail')]
        [String]$Treiber,
        [Validateset('Rechnung', 'Kulanz', 'Reklamation', 'Gutschrift', 'Kostenvoranschlag', 'Technikerlaufzettel')]
        [String]$Formular
    )

    If (Select-App -App $global:DlpAutoApp) {
        If (-Not ($IgnoreCall)) {
            Send-Key -Keys "{F6}"
            Start-Sleep -Milliseconds 200
        }

        Start-Sleep -Milliseconds 200

        # Druckertreiberauswahl
        Switch ($Treiber) {
            'Win'       {Send-Key -Keys "w"}
            'Ansicht'   {Send-Key -Keys "a"}
            'E-Mail'    {Send-Key -Keys "e"}
        }
        Send-Key -Keys "{DOWN}"
        Start-Sleep -Milliseconds 200

        # TODO: Schachtauswahl

        # Formularauswahl
        Switch ($Formular) {
            'Rechnung'  {Send-Key -Keys 'r'}
            'Gutschrift'  {Send-Key -Keys 'g'}
            'Kostenvoranschlag'  {Send-Key -Keys 'k'}
            'Technikerlaufzettel'  {Send-Key -Keys 't'}
            # TODO: Rest
        }
        Send-Key -Keys "{DOWN}"
        Start-Sleep -Milliseconds 200

        # Auslösen
        Send-Key -Keys "{PGDN}"
    }
}
