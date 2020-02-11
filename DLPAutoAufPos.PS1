# DLPAutoAufPos.PS1

Function New-AufPos {
    [CmdletBinding()]
    Param(
        [String]$AufPosBelBebNr='10',
        [String]$AufPosMenge='1',
        [String]$AufPosTechniker='1'
    )
    
    Select-App -App "Delapro"
    Send-Key -Keys ' {LEFT}'
    Start-Sleep -Milliseconds 200
    Send-Key -Keys "$AufPosBelBebNr{PGDN}{RIGHT}"
    Start-Sleep -Milliseconds 200
    Send-Key -Keys "$AufPosMenge"
    Start-Sleep -Milliseconds 200
    Send-Key -Keys "{ENTER}"
    Start-Sleep -Milliseconds 200
    Send-Key -Keys "$AufPosTechniker{PGDN}"
    Start-Sleep -Milliseconds 200
    Send-Key -Keys "{DOWN}"

}

Function Exit-AufPos {
    [CmdletBinding()]
    Param(
        [Switch]$Save
    )

    Select-App -App "Delapro"
    If ($Save) {
        Send-Key -Keys "{F10}"
    } else {
        Send-Key -Keys "{ESC}"
    }

}