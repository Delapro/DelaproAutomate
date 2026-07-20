$ErrorActionPreference = 'Stop'
. (Join-Path (Split-Path -Parent $PSScriptRoot) 'DLPAutoCommon.PS1')

$TestDirectory = Join-Path ([System.IO.Path]::GetTempPath()) ("DLPIniTest-" + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $TestDirectory | Out-Null

try {
    $IniPath = Join-Path $TestDirectory 'DLP_MAIN.INI'

    @'
; Kommentar
[Modus]
BehandlerModulAktiv=1
'@ | Set-Content -LiteralPath $IniPath -Encoding UTF8

    If (-Not (Test-DLPBehandlerModulAktiv -IniPath $IniPath)) {
        throw 'Aktiver Behandlerschalter wurde nicht erkannt.'
    }

    @'
[modus]
BEHANDLERMODULAKTIV = "0"
'@ | Set-Content -LiteralPath $IniPath -Encoding UTF8

    If (Test-DLPBehandlerModulAktiv -IniPath $IniPath) {
        throw 'Deaktivierter Behandlerschalter wurde als aktiv erkannt.'
    }

    $Value = Get-DLPMainIniValue -Section 'Fehlt' -Key 'Fehlt' -DefaultValue 'Standard' -IniPath $IniPath
    If ($Value -ne 'Standard') {
        throw 'DefaultValue wurde nicht zurückgegeben.'
    }

    If (Test-DLPBehandlerModulAktiv -IniPath (Join-Path $TestDirectory 'nicht-vorhanden.ini')) {
        throw 'Eine fehlende INI darf das Behandlermodul nicht aktivieren.'
    }

    Write-Host 'DLP_MAIN.INI-Auswertung: OK'
} finally {
    Remove-Item -LiteralPath $TestDirectory -Recurse -Force -ErrorAction SilentlyContinue
}
