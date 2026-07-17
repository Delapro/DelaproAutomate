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
        [ScriptBlock]$OnBehandlerSelection,
        [ScriptBlock]$OnHeader,
        [ScriptBlock]$OnPositionEntry,
        [Switch]$StayInHeader
    )

    If ($StayInHeader -and (-Not ($OnHeader))) {
        throw 'StayInHeader ist nur noch zusammen mit OnHeader zulässig. Der Codeblock wird im Auftragskopf ausgeführt und anschließend mit F4 zur Positionserfassung gewechselt.'
    }
    If ($StayInHeader) {
        Write-Warning 'StayInHeader ist veraltet. Verwenden Sie direkt OnHeader.'
    }

    $BehandlerAktiv = Test-DLPBehandlerModulAktiv -IniPath $DlpMainIni
    If ($OnBehandlerSelection -and (-Not ($BehandlerAktiv))) {
        throw 'OnBehandlerSelection kann nur bei aktivem Behandlermodul verwendet werden.'
    }

    If (Select-App -App $global:DlpAutoApp) {
        Send-Key -Keys "{F2}$AufXMLNummer{ENTER}$($AufDatum.ToShortDateString()){ENTER}$AufKunNummer{ENTER}"

        # Bei aktivem Behandlermodul folgt direkt nach der Kundennummer das
        # Behandlerfeld. Für einen Screenshot kann zuvor die F2-Auswahl
        # geöffnet werden. Nach dem Codeblock wird sie wieder geschlossen.
        If ($BehandlerAktiv) {
            If ($OnBehandlerSelection) {
                Send-Key -Keys "{F2}"
                Invoke-DLPStateAction -Action $OnBehandlerSelection -Module 'Auftrag' -State 'BehandlerSelection' -Data @{
                    KundenNummer = $AufKunNummer
                    BehandlerNummer = $AufBehandlerNummer
                }
                Send-Key -Keys "{ESC}"
            }
            Send-Key -Keys "$AufBehandlerNummer{ENTER}"
        } elseif ($AufBehandlerNummer) {
            Write-Verbose 'Behandlernummer wird ignoriert, da das Behandlermodul nicht aktiv ist.'
        }

        Send-Key -Keys "{ENTER}{ENTER}{ENTER}{ENTER}$AufPatient{ENTER}$AufKrankenkasse{ENTER}$AufZahnfarbe{ENTER}$AufBeleg{ENTER}{ENTER}$AufArtDerArbeit"

        Invoke-DLPStateAction -Action $OnHeader -Module 'Auftrag' -State 'Header' -Data @{
            KundenNummer = $AufKunNummer
            BehandlerNummer = $AufBehandlerNummer
            Patient = $AufPatient
        }

        # F4 übernimmt den Auftragskopf und öffnet die Positionserfassung.
        # Dadurch bleibt kein nur für den Screenshot ausgefüllter Auftrag zurück.
        Send-Key -Keys "{F4}"
        Start-Sleep -Milliseconds 100

        Invoke-DLPStateAction -Action $OnPositionEntry -Module 'Auftrag' -State 'PositionEntry' -Data @{
            KundenNummer = $AufKunNummer
            BehandlerNummer = $AufBehandlerNummer
            Patient = $AufPatient
        }
    }
}

Function Show-NeuerAuftragBehandlerAuswahl {
    [CmdletBinding()]
    Param(
        [String]$AufXMLNummer='3-6-9',
        [String]$AufKunNummer='1',
        [AllowEmptyString()]
        [String]$AufBehandlerNummer='',
        [DateTime]$AufDatum=(Get-Date),
        [String]$AufPatient='Testpatient',
        [String]$DlpMainIni=$global:DlpAutoMainIni,
        [Parameter(Mandatory)]
        [ScriptBlock]$OnSelection
    )

    If (-Not (Test-DLPBehandlerModulAktiv -IniPath $DlpMainIni)) {
        throw 'Das Behandlermodul ist in der DLP_MAIN.INI nicht aktiviert.'
    }

    # Sichere Variante: Die Auswahl wird für den Codeblock geöffnet und der
    # Auftrag anschließend normal bis zur Positionserfassung angelegt.
    New-Auftrag -AufXMLNummer $AufXMLNummer -AufKunNummer $AufKunNummer -AufBehandlerNummer $AufBehandlerNummer -AufDatum $AufDatum -AufPatient $AufPatient -DlpMainIni $DlpMainIni -OnBehandlerSelection $OnSelection
}

Function Show-AuftragBehandlerAuswahl {
    [CmdletBinding()]
    Param(
        [String]$DlpMainIni=$global:DlpAutoMainIni,
        [ScriptBlock]$OnSelection
    )

    If (-Not (Test-DLPBehandlerModulAktiv -IniPath $DlpMainIni)) {
        throw 'Das Behandlermodul ist in der DLP_MAIN.INI nicht aktiviert.'
    }

    If (Select-App -App $global:DlpAutoApp) {
        # Startpunkt muss das Behandlerfeld im Auftragskopf sein!
        Send-Key -Keys "{F2}"
        Invoke-DLPStateAction -Action $OnSelection -Module 'Auftrag' -State 'BehandlerSelection' -Data @{}
        If ($OnSelection) {
            Send-Key -Keys "{ESC}"
        }
    }
}

Function Enter-Auftrag {

    If (Select-App -App $global:DlpAutoApp) {
        # Startpunkt muss das Hauptmenü sein!
        Send-Key -Keys "{F3}"
    }
}

Function Exit-Auftrag {
    [CmdletBinding()]
    Param(
        [Switch]$Save
    )

    # -Save nur verwenden, wenn eine Auftragseingabemaske geöffnet ist.
    # In der Auftragsübersicht kann F10 eine andere Funktion besitzen.
    Exit-DLPInputMask -Save:$Save
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
