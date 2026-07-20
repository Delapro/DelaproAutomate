$ErrorActionPreference = 'Stop'
$RepositoryRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $RepositoryRoot 'DLPAutoCommon.PS1')
. (Join-Path $RepositoryRoot 'DLPAutoKunde.ps1')

$script:SentKeys = New-Object 'System.Collections.Generic.List[string]'
$script:FirstPageCalled = $false

Function Select-App { $true }
Function Send-Key {
    Param([String]$Keys, [String]$SpecialKey)
    If ($PSBoundParameters.ContainsKey('Keys')) {
        $script:SentKeys.Add($Keys)
    }
}
Function Start-Sleep { Param([Int]$Milliseconds, [Int]$Seconds) }

New-Kunde -KunNummer '001' -KunName 'Testkunde' -OnFirstPage {
    $script:FirstPageCalled = $true
}

If (-Not $script:FirstPageCalled) {
    throw 'OnFirstPage wurde ohne OnSecondPage nicht ausgeführt.'
}
If ($script:SentKeys[0] -notlike '*001{ENTER}*') {
    throw "Kundennummer fehlt in der Tastensequenz: $($script:SentKeys[0])"
}
If (($script:SentKeys | Where-Object {$_ -eq '{F10}'}).Count -ne 3) {
    throw 'New-Kunde muss den mehrseitigen Datensatz mit drei F10-Schritten abschließen.'
}

Write-Host 'New-Kunde: OK'
