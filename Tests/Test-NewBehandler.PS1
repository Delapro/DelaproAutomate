$ErrorActionPreference = 'Stop'
$RepositoryRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $RepositoryRoot 'DLPAutoCommon.PS1')
. (Join-Path $RepositoryRoot 'DLPAutoBehandler.PS1')

$TestDirectory = Join-Path ([System.IO.Path]::GetTempPath()) ("DLPBehandlerTest-" + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $TestDirectory | Out-Null
$IniPath = Join-Path $TestDirectory 'DLP_MAIN.INI'
"[Modus]`r`nBehandlerModulAktiv=1" | Set-Content -LiteralPath $IniPath -Encoding ASCII

$script:Events = New-Object 'System.Collections.Generic.List[string]'
Function Select-App { $true }
Function Start-Sleep { Param([Int]$Milliseconds, [Int]$Seconds) }
Function Send-Key {
    Param([String]$Keys, [String]$SpecialKey)
    If ($PSBoundParameters.ContainsKey('Keys')) {
        $script:Events.Add("KEY:$Keys")
    }
}

try {
    New-Behandler -BehNummer '001' -BehVorname 'Anna' -BehName 'Weber' -DlpMainIni $IniPath `
        -OnFirstPage {$script:Events.Add('CALLBACK:FirstPage')} `
        -OnSecondPage {$script:Events.Add('CALLBACK:SecondPage')} `
        -OnSaved {$script:Events.Add('CALLBACK:Saved')}

    $FirstCallback = $script:Events.IndexOf('CALLBACK:FirstPage')
    $FirstSave = $script:Events.IndexOf('KEY:{F10}')
    $SecondCallback = $script:Events.IndexOf('CALLBACK:SecondPage')
    $SecondSave = $script:Events.LastIndexOf('KEY:{F10}')
    $SavedCallback = $script:Events.IndexOf('CALLBACK:Saved')

    If (($FirstCallback -lt 0) -or ($FirstSave -le $FirstCallback) -or
        ($SecondCallback -le $FirstSave) -or ($SecondSave -le $SecondCallback) -or
        ($SavedCallback -le $SecondSave)) {
        throw "Callback-/Speicherreihenfolge ist falsch: $($script:Events -join ', ')"
    }
    If (($script:Events | Where-Object {$_ -eq 'KEY:{F10}'}).Count -ne 2) {
        throw 'New-Behandler muss genau zweimal mit F10 speichern.'
    }

    Write-Host 'New-Behandler: OK'
} finally {
    Remove-Item -LiteralPath $TestDirectory -Recurse -Force -ErrorAction SilentlyContinue
}
