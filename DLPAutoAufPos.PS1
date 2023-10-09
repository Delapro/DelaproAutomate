# DLPAutoAufPos.PS1

Function New-AufPos {
    [CmdletBinding()]
    Param(
        [String]$BelBebNr='10',
        [String]$Menge='1',
        [String]$Techniker='1'
    )
    
    If (Select-App -App "Delapro") {
        Send-Key -Keys ' {LEFT}'
        Start-Sleep -Milliseconds 200
        Send-Key -Keys "$BelBebNr{PGDN}{RIGHT}"
        Start-Sleep -Milliseconds 200
        Send-Key -Keys "$Menge"
        Start-Sleep -Milliseconds 200
        Send-Key -Keys "{ENTER}"
        Start-Sleep -Milliseconds 200
        Send-Key -Keys "$Techniker{PGDN}"
        Start-Sleep -Milliseconds 200
        Send-Key -Keys "{DOWN}"
        Start-Sleep -Milliseconds 200
    }
}

Function Exit-AufPos {
    [CmdletBinding()]
    Param(
        [Switch]$Save,
        [Switch]$RemoveBlankRow
    )

    If (Select-App -App "Delapro") {
        If ($Save) {
            If ($RemoveBlankRow) {
                Send-Key -Keys "{UP}"
                Start-Sleep -Milliseconds 200
            }
            Send-Key -Keys "{F10}"
            Start-Sleep -Milliseconds 500
        } else {
            Send-Key -Keys "{ESC}"
            Start-Sleep -Milliseconds 200
        }
    }
}
