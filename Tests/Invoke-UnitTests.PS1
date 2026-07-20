$ErrorActionPreference = 'Stop'
$RepositoryRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $RepositoryRoot 'DLPAutoCommon.PS1')

$Tests = @(
    'Test-RepositorySyntax.PS1',
    'Test-FunctionLoading.PS1',
    'Test-DLPMainIni.PS1',
    'Test-DLPStateAction.PS1',
    'Test-DLPTuiGrid.PS1',
    'Test-NewKunde.PS1',
    'Test-NewAuftrag.PS1',
    'Test-NewBehandler.PS1',
    'Test-DocumentationScenario.PS1'
)

foreach ($TestName in $Tests) {
    $TestPath = Join-Path $PSScriptRoot $TestName
    If (-Not (Test-Path -LiteralPath $TestPath -PathType Leaf)) {
        throw "Testdatei fehlt: $TestName"
    }
    Write-Host "`n=== $TestName ===" -ForegroundColor Cyan
    & $TestPath
}

Write-Host "`nAlle Unit- und Ladetests waren erfolgreich." -ForegroundColor Green
