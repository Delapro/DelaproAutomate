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