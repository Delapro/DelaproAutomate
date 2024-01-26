# DLPAutoTechniker.PS1

Function New-Techniker {
    [CmdletBinding()]
    Param(
        [String]$TecAnrede='Herr',
        [String]$TecVorname='Vorname',
        [String]$TecName='Testtechniker',
        [String]$RFIDNr,
        [String]$Wochenzeitmodell
    )
    
    If (Select-App -App $global:DlpAutoApp) {
        Send-Key -Keys "{F2}{ENTER}{ENTER}$TecAnrede{ENTER}{ENTER}$TecVorname{ENTER}$TecName{PGDN}"
        If ($RFIDNr) {
            Enter-TechnikerRFID
            New-TechnikerRFID -RFID $RFIDNr
            Exit-TechnikerRFID
        }
        If ($Wochenzeitmodell) {
            Enter-TechnikerWochenzeitmodell
            New-TechnikerWochenzeitmodell -Wochenzeitmodell $Wochenzeitmodell
            Exit-TechnikerWochenzeitmodell
        }
        Send-Key -Keys "{PGDN}"
    }
}

Function Enter-Techniker {

    If (Select-App -App $global:DlpAutoApp) {
        # Startpunkt muss das Hauptmenü sein!
        Send-Key -Keys "{F7}"
    }
}

Function Exit-Techniker {

    If (Select-App -App $global:DlpAutoApp) {
        Send-Key -Keys "{ESC}"
    }
}

Function Enter-TechnikerRFID {

    If (Select-App -App $global:DlpAutoApp) {
        # Startpunkt muss die zweite Seite des Technikers sein!
        Send-Key -Keys "{F9}"
    }
}

Function Exit-TechnikerRFID {

    If (Select-App -App $global:DlpAutoApp) {
        Send-Key -Keys "{ESC}"
    }
}

Function New-TechnikerRFID {
    [CmdletBinding()]
    Param(
        [String]$RFIDNr
    )
    
    If (Select-App -App $global:DlpAutoApp) {
        Send-Key -Keys "{F2}$RFIDNr{PGDN}"
    }
}

Function Enter-TechnikerWochenzeitmodell {

    If (Select-App -App $global:DlpAutoApp) {
        # Startpunkt muss die zweite Seite des Technikers sein!
        Send-Key -Keys "{F8}"
    }
}

Function Exit-TechnikerWochenzeitmodell {

    If (Select-App -App $global:DlpAutoApp) {
        Send-Key -Keys "{ESC}"
    }
}

Function New-TechnikerWochenzeitmodell {
    [CmdletBinding()]
    Param(
        [String]$Wochenzeitmodell,
        [DateTime]$Von,
        [DateTime]$Bis
    )
    
    If (Select-App -App $global:DlpAutoApp) {
        Send-Key -Keys "{F2}$Wochenzeitmodell{DOWN}"
        If ($Von) {
            Send-Key -Keys "$($Von.ToString('d'))"
        }
        Send-Key -Keys "{DOWN}"
        If ($Bis) {
            Send-Key -Keys "$($Bis.ToString('d'))"
        }
        Send-Key -Keys "{DOWN}"
        Send-Key -Keys "{PGDN}"
    }
}
