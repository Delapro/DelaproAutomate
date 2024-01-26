# DLPAutoZeiterfassung.PS1

Function New-Wochenzeitmodell {
    [CmdletBinding()]
    Param(
         [String]$Nummer='1'
        ,[String]$Beschreibung='Wochenzeitmodell'
        ,[String]$Montag
        ,[String]$Dienstag
        ,[String]$Mittwoch
        ,[String]$Donnerstag
        ,[String]$Freitag
        ,[String]$Samstag
        ,[String]$Sonntag
    )
    
    If (Select-App -App $global:DlpAutoApp) {
        Send-Key -Keys "{F2}$(([int]$Nummer).ToString('0#')){ENTER}$Beschreibung{ENTER}$Montag{ENTER}$Dienstag{ENTER}$Mittwoch{ENTER}$Donnerstag{ENTER}$Freitag{ENTER}$Samstag{ENTER}$Sonntag{ENTER}"
        # restliche Parameter eintragen
        Send-Key -Keys "{PGDN}"
    }

}

Function Enter-Wochenzeitmodell {

    If (Select-App -App  $global:DlpAutoApp) {
        # Startpunkt muss das Hauptmenü sein!
        Send-Key -Keys "{F3}"
    }
}

Function Exit-Wochenzeitmodell {

    If (Select-App -App $global:DlpAutoApp) {
        Send-Key -Keys "{ESC}"
    }
}

Function New-Tageszeitmodell {
    [CmdletBinding()]
    Param(
         [String]$Nummer='1'
        ,[String]$Beschreibung='Tageszeitmodell'
        ,[Validateset('Festzeit', 'Gleitzeit', 'Additiv')]
         [String]$Zeitart
        ,[TimeSpan]$Sollzeit
    )
    
    If (Select-App -App $global:DlpAutoApp) {
        Send-Key -Keys "{F2}$(([int]$Nummer).ToString('0#')){ENTER}$Beschreibung{ENTER}"
        switch ($Zeitart) {
            'Festzeit'   {Send-Key -Keys 'F'}
            'Gleitzeit'  {Send-Key -Keys 'G'}
            'Additiv'    {Send-Key -Keys 'A'}
        }
        Send-Key -Keys "{DOWN}"
        Send-Key -Keys "$($SollZeit.ToString('hh\:mm'))"
        # restliche Parameter eintragen
        Send-Key -Keys "{PGDN}"
    }

}

Function Enter-Tageszeitmodell {

    If (Select-App -App  $global:DlpAutoApp) {
        # Startpunkt muss das Hauptmenü sein!
        Send-Key -Keys "{F4}"
    }
}

Function Exit-Tageszeitmodell {

    If (Select-App -App $global:DlpAutoApp) {
        Send-Key -Keys "{ESC}"
    }
}

