# Einfacher Test ohne Pester.

$TestResult = $null
Invoke-DLPStateAction -Module 'TestModul' -State 'TestZustand' -Data @{Wert='OK'} -Action {
    param($Context)
    $script:TestResult = "$($Context.Module)|$($Context.State)|$($Context.Data.Wert)"
}

If ($TestResult -ne 'TestModul|TestZustand|OK') {
    throw "Invoke-DLPStateAction lieferte ein unerwartetes Ergebnis: $TestResult"
}

Write-Host 'Invoke-DLPStateAction: OK'
