$ErrorActionPreference = 'Stop'

$RepositoryRoot = Split-Path -Parent $PSScriptRoot
$LoadFiles = @(
    'DLPAutoCommon.PS1'
)
$LoadFiles += Get-ChildItem -LiteralPath $RepositoryRoot -Filter 'DLPAuto*.PS1' -File |
    Where-Object Name -ne 'DLPAutoCommon.PS1' |
    Sort-Object Name |
    Select-Object -ExpandProperty Name
$LoadFiles += 'DLPAutomateBehandlerDocument.PS1'

$ExpectedFunctions = New-Object 'System.Collections.Generic.List[string]'

foreach ($FileName in $LoadFiles) {
    $FilePath = Join-Path $RepositoryRoot $FileName
    If (-Not (Test-Path -LiteralPath $FilePath -PathType Leaf)) {
        throw "Zu ladende Datei fehlt: $FileName"
    }

    $Tokens = $null
    $Errors = $null
    $Ast = [System.Management.Automation.Language.Parser]::ParseFile(
        $FilePath,
        [ref]$Tokens,
        [ref]$Errors
    )
    If ($Errors.Count -gt 0) {
        throw "Datei kann nicht geladen werden: $FileName"
    }

    foreach ($Statement in $Ast.EndBlock.Statements) {
        If ($Statement -is [System.Management.Automation.Language.FunctionDefinitionAst]) {
            $ExpectedFunctions.Add($Statement.Name)
        }
    }

    . $FilePath
}

$MissingFunctions = foreach ($FunctionName in ($ExpectedFunctions | Sort-Object -Unique)) {
    If (-Not (Get-Command -Name $FunctionName -CommandType Function -ErrorAction SilentlyContinue)) {
        $FunctionName
    }
}

If ($MissingFunctions) {
    throw "Funktionen wurden nicht geladen: $($MissingFunctions -join ', ')"
}

Initialize-Automation
If ($global:DlpAutoApp -ne 'Delapro') {
    throw 'Initialize-Automation hat DlpAutoApp nicht gesetzt.'
}
If (($global:DlpAutoTuiRows -ne 25) -or ($global:DlpAutoTuiColumns -ne 80)) {
    throw 'Initialize-Automation hat das TUI-Raster nicht korrekt gesetzt.'
}

Write-Host "Funktionsladen: OK ($($ExpectedFunctions.Count) Funktionsdefinitionen)"
