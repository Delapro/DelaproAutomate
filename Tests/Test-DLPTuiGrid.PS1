# Einfacher Berechnungstest ohne echtes Delapro-Fenster.

. (Join-Path -Path $PSScriptRoot -ChildPath '..\DLPAutoCommon.PS1')

$global:DlpAutoTuiRows = 25
$global:DlpAutoTuiColumns = 80

# Die Fensterabfrage wird für diesen Test durch einen festen Clientbereich ersetzt.
Function Get-DLPWindowRectangle {
    New-Object System.Drawing.Rectangle -ArgumentList 100, 200, 800, 500
}

$First = Get-DLPTuiCellPoint -Row 1 -Column 1
If (($First.X -ne 105) -or ($First.Y -ne 210)) {
    throw "Erste TUI-Zelle falsch berechnet: $($First.X), $($First.Y)"
}

$Last = Get-DLPTuiCellPoint -Row 25 -Column 80
If (($Last.X -ne 895) -or ($Last.Y -ne 690)) {
    throw "Letzte TUI-Zelle falsch berechnet: $($Last.X), $($Last.Y)"
}

$Padded = Get-DLPTuiCellPoint -Row 1 -Column 1 `
    -PaddingLeft 10 -PaddingTop 10 -PaddingRight 10 -PaddingBottom 10
If (($Padded.X -ne 115) -or ($Padded.Y -ne 220)) {
    throw "TUI-Zelle mit Padding falsch berechnet: $($Padded.X), $($Padded.Y)"
}

Write-Host 'TUI-Rasterberechnung: OK'
