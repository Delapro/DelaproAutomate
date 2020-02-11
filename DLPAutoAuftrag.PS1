# DLPAutoAuftrag.PS1

Function New-Auftrag {
    [CmdletBinding()]
    Param(
        [String]$AufXMLNummer='3-6-9',
        [String]$AufKunNummer='1',
        [DateTime]$AufDatum=(Get-Date),
        [String]$AufPatient='Testpatient',
        [String]$AufKrankenkasse='Privat',
        [String]$AufZahnfarbe='A3',
        [String]$AufBeleg='Beleg',
        [String]$AufArtDerArbeit='Reparatur'
    )
    
    Select-App -App "Delapro"
    Send-Key -Keys "{F2}$AufXMLNummer{ENTER}$($AufDatum.ToShortDateString()){ENTER}$AufKunNummer{ENTER}{ENTER}{ENTER}{ENTER}{ENTER}$AufPatient{ENTER}$AufKrankenkasse{ENTER}$AufZahnfarbe{ENTER}$AufBeleg{ENTER}{ENTER}$AufArtDerArbeit{F4}"

}

Function Enter-Auftrag {

    Select-App -App "Delapro"
    # Startpunkt muss das Hauptmenü sein!
    Send-Key -Keys "{F3}"

}

Function Exit-Auftrag {

    Select-App -App "Delapro"
    Send-Key -Keys "{ESC}"

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

    Select-App -App "Delapro"
    If (-Not ($IgnoreCall)) {
        Send-Key -Keys "{F6}"
    }

    # Druckertreiberauswahl
    Switch ($Treiber) {
        'Win'       {Send-Key -Keys "w"}
        'Ansicht'   {Send-Key -Keys "a"}
        'E-Mail'    {Send-Key -Keys "e"}
    }
    Send-Key -Keys "{DOWN}"

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

    # Auslösen
    Send-Key -Keys "{PGDN}"
}