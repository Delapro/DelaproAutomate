# DLPAutomateBehandlerDocumentation.PS1
# Beispielablauf zum Erzeugen reproduzierbarer Behandlerdaten.
# Das Skript führt beim Dot-Sourcing nichts automatisch aus.

Function New-BehandlerDokumentationsStammdaten {
    [CmdletBinding()]
    Param(
        [String]$KunNummer='001'
    )

    If (-Not (Test-DLPBehandlerModulAktiv)) {
        throw 'Für dieses Szenario muss [Modus] BehandlerModulAktiv=1 gesetzt sein.'
    }

    Enter-Kunde
    New-Kunde -KunNummer $KunNummer -KunAnrede 'Praxis' -KunName 'Gemeinschaftspraxis am Stadtpark'

    Enter-KundeBehandler
    New-Behandler -BehNummer '001' -BehAnrede 'Zahnärztin' -BehTitel 'Dr. med. dent.' -BehVorname 'Anna' -BehName 'Weber' -BehEMail 'anna.weber@example.invalid'
    New-Behandler -BehNummer '002' -BehAnrede 'Zahnarzt' -BehTitel 'Dr. med. dent.' -BehVorname 'Markus' -BehName 'Klein' -BehEMail 'markus.klein@example.invalid'
    New-Behandler -BehNummer '003' -BehAnrede 'Zahnärztin' -BehTitel 'Dr. med. dent.' -BehVorname 'Lea' -BehName 'Vogel' -BehEMail 'lea.vogel@example.invalid'
    Exit-KundeBehandler

    # Ein ESC beendet die Kundendaten, ein weiteres die Kundenübersicht.
    Exit-Kunde
    Exit-Kunde
}

Function New-BehandlerDokumentationsAuftrag {
    [CmdletBinding()]
    Param(
        [String]$KunNummer='001',
        [AllowEmptyString()]
        [String]$BehandlerNummer='',
        [String]$Patient='Dokumentation, Test'
    )

    Enter-Auftrag
    New-Auftrag -AufKunNummer $KunNummer -AufBehandlerNummer $BehandlerNummer -AufPatient $Patient
}
