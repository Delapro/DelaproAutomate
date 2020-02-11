# DLPAutoTechniker.PS1

Function New-Techniker {
    [CmdletBinding()]
    Param(
        [String]$TecAnrede='Herr',
        [String]$TecVorname='Vorname',
        [String]$TecName='Testtechniker'    
    )
    
    Select-App -App "Delapro"
    Send-Key -Keys "{F2}{ENTER}{ENTER}$TecAnrede{ENTER}{ENTER}$TecVorname{ENTER}$TecName{PGDN}{PGDN}"

}

Function Enter-Techniker {

    Select-App -App "Delapro"
    # Startpunkt muss das Hauptmenü sein!
    Send-Key -Keys "{F7}"

}

Function Exit-Techniker {

    Select-App -App "Delapro"
    Send-Key -Keys "{ESC}"

}