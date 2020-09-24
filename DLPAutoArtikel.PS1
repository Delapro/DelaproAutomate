# DLPAutoArtikel.PS1

Function New-Artikel {
    [CmdletBinding()]
    Param(
        [String]$BelbebNr,
        [String]$BebArt,
        [String]$Artikelgruppe,
        [String]$Text,
        [Decimal]$Preis
    )
    
    If (Select-App -App "Delapro") {
        Send-Key -Keys "{F2}"  # Anlegen
        
        # Anlegenmaske ausfüllen
        Send-Key "$BelBebNr{ENTER}"
        Send-Key "$BebArt{ENTER}"
        Send-Key "$Artikelgruppe{ENTER}"
        Send-Key "$Text{ENTER}"
        Send-Key "$Preis{ENTER}"
        
        # Speichern
        Send-Key "{F10}"
    }
}

Function New-BEB7 {
    [CmdletBinding()]
    Param(
        [String]$BelbebNr='850000',
        [String]$BebArt='BEB7',
        [String]$Artikelgruppe='L',
        [String]$Text='Spezialreparatur',
        [Decimal]$Preis=123.5
    )

    New-Artikel -BelbebNr $BelbebNr -BebArt $BebArt -Artikelgruppe $Artikelgruppe -Text $Text
}

Function New-BEL2 {
    [CmdletBinding()]
    Param(
        [String]$BelbebNr='850000',
        [String]$BebArt='BEL2',
        [String]$Artikelgruppe='L',
        [String]$Text='Spezialreparatur',
        [Decimal]$Preis=99.5
    )

    New-Artikel -BelbebNr $BelbebNr -BebArt $BebArt -Artikelgruppe $Artikelgruppe -Text $Text

}

Function New-Material {
    [CmdletBinding()]
    Param(
        [String]$BelbebNr='900000',
        [String]$BebArt='    ',
        [String]$Artikelgruppe='E',
        [String]$Text='Testmaterial',
        [Decimal]$Preis=12.63
    )

    New-Artikel -BelbebNr $BelbebNr -BebArt $BebArt -Artikelgruppe $Artikelgruppe -Text $Text

}

Function Enter-Artikel {

    If (Select-App -App "Delapro") {
        # Startpunkt muss das Hauptmenü sein!
        Send-Key -Keys "{F4}"  # Leistungs/Materialverwaltung
    }
}

Function Exit-Artikel {

    If (Select-App -App "Delapro") {
        Send-Key -Keys "{ESC}"
    }
}