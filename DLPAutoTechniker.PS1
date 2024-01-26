# DLPAutoTechniker.PS1

Function New-Techniker {
    [CmdletBinding()]
    Param(
        [String]$TecAnrede='Herr',
        [String]$TecVorname='Vorname',
        [String]$TecName='Testtechniker'    
    )
    
    If (Select-App) {
        Send-Key -Keys "{F2}{ENTER}{ENTER}$TecAnrede{ENTER}{ENTER}$TecVorname{ENTER}$TecName{PGDN}{PGDN}"
    }
}

Function Enter-Techniker {

    If (Select-App) {
        # Startpunkt muss das Hauptmenü sein!
        Send-Key -Keys "{F7}"
    }
}

Function Exit-Techniker {

    If (Select-App) {
        Send-Key -Keys "{ESC}"
    }
}
