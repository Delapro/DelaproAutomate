# DLPAutomateBehandlerDocumentation.PS1
# Beispielablauf zum Erzeugen reproduzierbarer Behandlerdaten und Bilder.
# Das Skript führt beim Dot-Sourcing nichts automatisch aus.

Function New-BehandlerDokumentationsStammdaten {
    [CmdletBinding()]
    Param(
        [String]$KunNummer='001',
        [String]$ImageDirectory
    )

    If (-Not (Test-DLPBehandlerModulAktiv)) {
        throw 'Für dieses Szenario muss [Modus] BehandlerModulAktiv=1 gesetzt sein.'
    }

    $KundeParameter = @{}
    $BehandlerParameter = @{}

    If ($ImageDirectory) {
        $KundeParameter.OnFirstPage = {
            param($Context)
            Save-DLPDocumentationWindow -Path (Join-Path $ImageDirectory '01-Kunde-anlegen-Seite1.png')
        }.GetNewClosure()
        $KundeParameter.OnSecondPage = {
            param($Context)
            Save-DLPDocumentationWindow -Path (Join-Path $ImageDirectory '02-Kunde-anlegen-Seite2.png')
        }.GetNewClosure()
        $KundeParameter.OnThirdPage = {
            param($Context)
            Save-DLPDocumentationWindow -Path (Join-Path $ImageDirectory '03-Kunde-anlegen-Seite3.png')
        }.GetNewClosure()

        $BehandlerParameter.OnFirstPage = {
            param($Context)
            Save-DLPDocumentationWindow -Path (Join-Path $ImageDirectory '04-Behandler-anlegen-Seite1.png')
        }.GetNewClosure()
        $BehandlerParameter.OnSecondPage = {
            param($Context)
            Save-DLPDocumentationWindow -Path (Join-Path $ImageDirectory '05-Behandler-anlegen-Seite2.png')
        }.GetNewClosure()
    }

    Enter-Kunde
    New-Kunde -KunNummer $KunNummer -KunAnrede 'Praxis' -KunName 'Gemeinschaftspraxis am Stadtpark' @KundeParameter

    Enter-KundeBehandler
    New-Behandler -BehNummer '001' -BehAnrede 'Zahnärztin' -BehTitel 'Dr. med. dent.' -BehVorname 'Anna' -BehName 'Weber' -BehEMail 'anna.weber@example.invalid' @BehandlerParameter
    New-Behandler -BehNummer '002' -BehAnrede 'Zahnarzt' -BehTitel 'Dr. med. dent.' -BehVorname 'Markus' -BehName 'Klein' -BehEMail 'markus.klein@example.invalid'
    New-Behandler -BehNummer '003' -BehAnrede 'Zahnärztin' -BehTitel 'Dr. med. dent.' -BehVorname 'Lea' -BehName 'Vogel' -BehEMail 'lea.vogel@example.invalid'
    
    If ($ImageDirectory) {
        Save-DLPDocumentationWindow -Path (Join-Path $ImageDirectory '06-Behandlerverwaltung.png')

        Select-Behandler -Suchbegriff '001'
        Show-BehandlerUmsatz
        Save-DLPDocumentationWindow -Path (Join-Path $ImageDirectory '07-Behandler-F9-Umsatz.png')
        Exit-BehandlerUmsatz
    }
    Exit-KundeBehandler

    # Zurück aus der Kundeneingabemaske in die Kundenübersicht und anschließend
    # aus der Kundenverwaltung. Es wurden keine Kundendaten geändert, daher ESC.
    Exit-Kunde
    Exit-Kunde
}

Function New-BehandlerDokumentationsAuftrag {
    [CmdletBinding()]
    Param(
        [String]$KunNummer='001',
        [AllowEmptyString()]
        [String]$BehandlerNummer='',
        [String]$Patient='Dokumentation, Test',
        [String]$ImageDirectory
    )

    $AuftragParameter = @{}
    If ($ImageDirectory) {
        $AuftragParameter.OnBehandlerSelection = {
            param($Context)
            Save-DLPDocumentationWindow -Path (Join-Path $ImageDirectory '08-Auftrag-Behandlerauswahl.png')
        }.GetNewClosure()
        $AuftragParameter.OnHeader = {
            param($Context)
            Save-DLPDocumentationWindow -Path (Join-Path $ImageDirectory '09-Auftrag-mit-Behandler.png')
        }.GetNewClosure()
    }

    Enter-Auftrag
    New-Auftrag -AufKunNummer $KunNummer -AufBehandlerNummer $BehandlerNummer -AufPatient $Patient @AuftragParameter
}
