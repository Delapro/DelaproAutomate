$ErrorActionPreference = 'Stop'
$RepositoryRoot = Split-Path -Parent $PSScriptRoot
$ScenarioPath = Join-Path $RepositoryRoot 'DLPAutomateBehandlerDocument.PS1'
$Scenario = Get-Content -LiteralPath $ScenarioPath -Raw

$HandlerMatches = [Regex]::Matches(
    $Scenario,
    'New-Behandler\s+-BehNummer\s+[''''"](?<Number>\d{1,3})[''''"]'
)
$HandlerNumbers = @($HandlerMatches | ForEach-Object {$_.Groups['Number'].Value})
$Duplicates = @($HandlerNumbers | Group-Object | Where-Object Count -gt 1)

If ($Duplicates) {
    throw "Behandlernummern werden im Dokumentationsszenario mehrfach angelegt: $($Duplicates.Name -join ', ')"
}
foreach ($ExpectedNumber in @('001', '002', '003')) {
    If ($HandlerNumbers -notcontains $ExpectedNumber) {
        throw "Behandler $ExpectedNumber fehlt im Dokumentationsszenario."
    }
}

$FilesToCheck = @(
    (Join-Path $RepositoryRoot 'README.md'),
    $ScenarioPath,
    (Join-Path $RepositoryRoot 'DLPAutoAuftrag.PS1')
)
foreach ($FilePath in $FilesToCheck) {
    $Content = Get-Content -LiteralPath $FilePath -Raw
    $InvalidNumbers = [Regex]::Matches(
        $Content,
        '-(?:KunNummer|AufKunNummer)\s+[''''"](?<Number>\d{4,})[''''"]'
    )
    If ($InvalidNumbers.Count -gt 0) {
        throw "Zu lange Kundennummer in $FilePath: $($InvalidNumbers[0].Groups['Number'].Value)"
    }
}

Write-Host 'Dokumentationsdaten: OK'
