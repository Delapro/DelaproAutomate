# DLPAutoJumbo.PS1

Function New-Jumbo {
    [CmdletBinding()]
    Param(
        [String]$Name='14er',
        [String]$Bemerkung='Kunststoffprothese 14er',
        [String]$SofortEinspielen='J',
        [String]$Abrechnungsart='L'
    )
    
    If (Select-App -App "Delapro") {
        Send-Key -Keys "{F2}$Name{ENTER}$Bemerkung{ENTER}$SofortEinspielen{ENTER}$Abrechnungsart{ENTER}"

        # jetzt sollte an JumboPos übergeben werden, wir kürzen ab!
        Send-Key -Keys "{F10}" # Speichern
    }
}

Function Enter-Jumbo {

    If (Select-App -App "Delapro") {
        # Startpunkt muss das Hauptmenü sein!
        Send-Key -Keys "{F5}"
    }
}

Function Exit-Jumbo {

    If (Select-App -App "Delapro") {
        Send-Key -Keys "{ESC}"
    }
}
