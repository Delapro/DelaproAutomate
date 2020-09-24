# DLPAutoCommon.PS1

# benötigt .Net Framework 4.8
# TODO: auf PS7 testen

Function Initialize-Automation {

    Add-Type -AssemblyName System.Windows.Forms
    [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
    [void] [System.Reflection.Assembly]::LoadWithPartialName("'System.Drawing")
    Add-Type -AssemblyName System.Speech

}

# Funktioniert nicht bei Consolen-Fenstern!!!
Function Select-App {
    [CmdletBinding()]
    Param(
        [Parameter(ParameterSetName='title', Position=0)]
        [ValidateNotNullOrEmpty()]
        [String]$App,
		[Parameter(ParameterSetName='process', Position=0)]
        [ValidateNotNullOrEmpty()]
        [int]$ProcessID
	)

	switch -exact ($PSCmdlet.ParameterSetName) {
	    { @('title') -contains $_} {
                        If (Get-Process -Name $App) {
                            [Microsoft.VisualBasic.Interaction]::AppActivate($App)
                            $true
                        } else {
                            $false
                        }
					               }
        { @('process') -contains $_} { 
                        If (Get-Process -Id $ProcessID) {
                            [Microsoft.VisualBasic.Interaction]::AppActivate($ProcessID)
                            $true
                        } else {
                            $false
                        }
                                     }
                
    }

    <#
    $wshell = New-Object -ComObject WScript.Shell    
$id = (gps iex* | where {$_.MainWindowTitle -match "Title"}).id    
$wshell.AppActivate($id)  
$id = (gps iex* | where {$_.MainWindowTitle -match "Delapro"}).id    
$wshell.AppActivate($id)  
gps iex*
gps dela*
$id = (gps dela* | where {$_.MainWindowTitle -match "Delapro"}).id    
$wshell.AppActivate($id)  
$id
gps dela*
(gps dela*).MainWindowHandle
(gps dela*).MainWindowTitle
$id=4588
$wshell.AppActivate($id)  
$wshell

    #>
}

Function Send-Key {
    [CmdletBinding()]
    Param(
        [String]$Keys,
        [ValidateSet('WinKey')]
        [String]$SpecialKey
    )

    Switch ($SpecialKey) {
        'Win' {$SpecialKey='^{ESC}'}
    }
    # https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.sendkeys?view=netframework-4.7.2
    If ($Keys) {
        [System.Windows.Forms.SendKeys]::SendWait($Keys)
    }
}

Function Copy-Screen {
    [CmdletBinding()]
    Param(
        [int]$X,
        [int]$Y,
        [int]$Width,
        [int]$Height,
        [String]$path=(New-TemporaryFile)
    )

    $bounds = [System.Drawing.Rectangle]::FromLTRB($X, $Y, $Width, $Height)
    $bmp = New-Object Drawing.Bitmap $bounds.width, $bounds.height
    $graphics = [System.Drawing.Graphics]::FromImage($bmp)
    $graphics.CopyFromScreen($bounds.Location.X, $bounds.Location.Y, 0, 0, $bound.Size)
    $bmp.Save($path)
    $graphics.Dispose()
    $bmp.Dispose()

    $path
}

Function Save-ActiveWindow {
    [CmdletBinding()]
    Param(
        [String]$Path=((New-TemporaryFile).Fullname.Replace('.tmp', '.png')),
        [String]$App='Delapro'
    )

    Select-App -App $App
    Send-Key -Keys "%{PrtSc}"
    Start-Sleep -Milliseconds 200

    $bitmap = [Windows.Forms.Clipboard]::GetImage()
    $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)

    $path
}

Function Exit-AcrobatReader {

    $reader = "AcroRd32"

    Start-Sleep -Milliseconds 200

    If ($p=Get-Process -Name $reader) {
        $p | Stop-Process -Force
    }
}

Function Out-Speech {
    [CmdletBinding()]
    Param(
        [String]$Text,
        [Switch]$Asnyc
    )

    $voice = New-Object System.Speech.Synthesis.SpeechSynthesizer
    If ($Asnyc) {
        $ret = $voice.SpeakAsync($Text)
        $ret
    } else {
        $voice.Speak($Text)
    }

}

Function Wait-Speech {
    [CmdletBinding()]
    Param(
        [System.Speech.Synthesis.Prompt]$SpeechRet
    )

    While (-not ($SpeechRet.IsCompleted)) {
        Start-Sleep -Milliseconds 100
    }
}