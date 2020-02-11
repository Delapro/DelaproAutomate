# DLPAutoKunde.PS1

Function New-Kunde {
    [CmdletBinding()]
    Param(
        [String]$KunAnrede='Zahnarzt',
        [String]$KunTitel='Dr.',
        [String]$KunVorname='Vorname',
        [String]$KunName='Tester'    
    )
    
    Select-App -App "Delapro"
    Send-Key -Keys "{F2}{ENTER}{ENTER}$KunAnrede{ENTER}$KunTitel{ENTER}$KunVorname{ENTER}$KunName{PGDN}{PGDN}{PGDN}"

}

Function Enter-Kunde {

    Select-App -App "Delapro"
    # Startpunkt muss das Hauptmenü sein!
    Send-Key -Keys "{F2}"

}

Function Exit-Kunde {

    Select-App -App "Delapro"
    Send-Key -Keys "{ESC}"

}