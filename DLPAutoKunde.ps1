# DLPAutoKunde.PS1

Function New-Kunde {
    [CmdletBinding()]
    Param(
        [String]$KunAnrede='Zahnarzt',
        [String]$KunTitel='Dr.',
        [String]$KunVorname='Vorname',
        [String]$KunName='Tester'    
    )
    
    If (Select-App -App "Delapro") {
        Send-Key -Keys "{F2}{ENTER}{ENTER}$KunAnrede{ENTER}$KunTitel{ENTER}$KunVorname{ENTER}$KunName{PGDN}"
        # zweite Seite
        Send-Key -Keys "{PGDN}"
        # dritte Seite
        Send-Key -Keys "{PGDN}"
    }
}

Function Enter-Kunde {

    If (Select-App -App "Delapro") {
        # Startpunkt muss das Hauptmenü sein!
        Send-Key -Keys "{F2}"
    }
}

Function Exit-Kunde {

    If (Select-App -App "Delapro") {
        Send-Key -Keys "{ESC}"
    }
}