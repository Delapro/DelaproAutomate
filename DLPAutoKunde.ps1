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
    Send-Key -Keys "{F2}{F2}{ENTER}{ENTER}$KunAnrede{ENTER}$KunTitel{ENTER}$KunVorname{ENTER}$KunName{PGDN}{PGDN}{PGDN}{ESC}"

}