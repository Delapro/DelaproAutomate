# DLPAutoAuftrag.PS1

Function New-Auftrag {
    [CmdletBinding()]
    Param(
        [String]$AufXMLNummer='3-6-9',
        [String]$AufKunNummer='1',
        [Date]$AufDatum=(Get-Date),
        [String]$AufPatient='Testpatient',
        [String]$AufKrankenkasse='Privat',
        [String]$AufZahnfarbe='A3',
        [String]$AufBeleg='Beleg',
        [String]$AufArtDerArbeit='Reparatur'
    )
    
    Select-App -App "Delapro"
    Send-Key -Keys "{F3}{F2}$AufXMLNummer{ENTER}$($AufDatum.ToShortDateString()){ENTER}$AufKunNummer{ENTER}{ENTER}{ENTER}{ENTER}{ENTER}$AufPatient{ENTER}$AufKrankenkasse{ENTER}$AufZahnfarbe{ENTER}$AufBeleg{ENTER}{ENTER}$AufArtDerArbeit{F4}"

}
