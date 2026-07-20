$ErrorActionPreference = 'Stop'
$RepositoryRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $RepositoryRoot 'DLPAutoCommon.PS1')
. (Join-Path $RepositoryRoot 'DLPAutoAuftrag.PS1')

$TestDirectory = Join-Path ([System.IO.Path]::GetTempPath()) ("DLPAuftragTest-" + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $TestDirectory | Out-Null

Function Select-App { $true }
Function Start-Sleep { Param([Int]$Milliseconds, [Int]$Seconds) }
Function Send-Key {
    Param([String]$Keys, [String]$SpecialKey)
    If ($PSBoundParameters.ContainsKey('Keys')) {
        $script:SentKeys.Add($Keys)
    }
}

try {
    $ActiveIni = Join-Path $TestDirectory 'active.ini'
    $InactiveIni = Join-Path $TestDirectory 'inactive.ini'
    "[Modus]`r`nBehandlerModulAktiv=1" | Set-Content -LiteralPath $ActiveIni -Encoding ASCII
    "[Modus]`r`nBehandlerModulAktiv=0" | Set-Content -LiteralPath $InactiveIni -Encoding ASCII

    $script:SentKeys = New-Object 'System.Collections.Generic.List[string]'
    New-Auftrag -AufKunNummer '001' -AufBehandlerNummer '002' -DlpMainIni $ActiveIni -AufDatum ([DateTime]'2026-01-15')
    If ($script:SentKeys[0] -notlike '*001{ENTER}') {
        throw 'Die Kundennummer wurde im aktiven Fall nicht korrekt abgeschlossen.'
    }
    If (-Not ($script:SentKeys -contains '002{ENTER}')) {
        throw 'Der Behandler wurde bei aktivem Modul nicht eingetragen.'
    }
    If ($script:SentKeys[-1] -ne '{F4}') {
        throw 'Der Auftragskopf wurde nicht mit F4 übernommen.'
    }

    $script:SentKeys = New-Object 'System.Collections.Generic.List[string]'
    New-Auftrag -AufKunNummer '001' -AufBehandlerNummer '' -DlpMainIni $ActiveIni -AufDatum ([DateTime]'2026-01-15')
    If (-Not ($script:SentKeys -contains '{ENTER}')) {
        throw 'Ein bewusst leerer Behandler wurde nicht bestätigt.'
    }

    $script:SentKeys = New-Object 'System.Collections.Generic.List[string]'
    New-Auftrag -AufKunNummer '001' -AufBehandlerNummer '002' -DlpMainIni $InactiveIni -AufDatum ([DateTime]'2026-01-15')
    If ($script:SentKeys -contains '002{ENTER}') {
        throw 'Bei deaktiviertem Modul wurde dennoch ein Behandlerfeld bedient.'
    }

    $script:SentKeys = New-Object 'System.Collections.Generic.List[string]'
    $script:SelectionCalled = $false
    New-Auftrag -AufKunNummer '001' -AufBehandlerNummer '002' -DlpMainIni $ActiveIni `
        -AufDatum ([DateTime]'2026-01-15') -OnBehandlerSelection {
            $script:SelectionCalled = $true
        }
    If (-Not $script:SelectionCalled) {
        throw 'OnBehandlerSelection wurde nicht ausgeführt.'
    }
    $F2Index = $script:SentKeys.IndexOf('{F2}')
    $EscIndex = $script:SentKeys.IndexOf('{ESC}')
    $HandlerIndex = $script:SentKeys.IndexOf('002{ENTER}')
    If (($F2Index -lt 0) -or ($EscIndex -le $F2Index) -or ($HandlerIndex -le $EscIndex)) {
        throw 'Reihenfolge Auswahl öffnen, schließen und Behandler eingeben ist falsch.'
    }

    Write-Host 'New-Auftrag: OK'
} finally {
    Remove-Item -LiteralPath $TestDirectory -Recurse -Force -ErrorAction SilentlyContinue
}
