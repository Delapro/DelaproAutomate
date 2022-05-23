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
                            If ($global:DlpAutoSelectAppSleep) {
                                Start-Sleep -Milliseconds $global:DlpAutoSelectAppSleep
                            }
                            $true
                        } else {
                            $false
                        }
					               }
        { @('process') -contains $_} { 
                        If (Get-Process -Id $ProcessID) {
                            [Microsoft.VisualBasic.Interaction]::AppActivate($ProcessID)
                            If ($global:DlpAutoSelectAppSleep) {
                                Start-Sleep -Milliseconds $global:DlpAutoSelectAppSleep
                            }
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
        If ($global:DlpAutoSendKeySleep) {
            Start-Sleep -Milliseconds $global:DlpAutoSendKeySleep
        }
    }
}

Function Set-MousePosition {
    [CmdletBinding()]
    Param(
        [int]$XPos,
        [int]$YPos
    )

    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($XPos,$YPos)

}

Function Invoke-MouseEvent {
    [CmdletBinding()]
    Param(
        [Validateset('LeftClick', 'RightClick', 'MiddleClick', 'Wheel')]
        [string]$Button='LeftClick',
        [int]$Delta
    )

    $signature=@' 
    [DllImport("user32.dll",CharSet=CharSet.Auto, CallingConvention=CallingConvention.StdCall)]
    public static extern void mouse_event(long dwFlags, long dx, long dy, long cButtons, long dwExtraInfo);
'@ 

    # https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.control.mousewheel?view=net-5.0
    $SendMouseEvent = Add-Type -memberDefinition $signature -name "Win32MouseEventNew" -namespace Win32Functions -passThru 
    if($Button -eq "LeftClick")
    {
        $SendMouseEvent::mouse_event(0x00000002, 0, 0, 0, 0);
        $SendMouseEvent::mouse_event(0x00000004, 0, 0, 0, 0);
    }
    if($Button -eq "RightClick")
    {
        $SendMouseEvent::mouse_event(0x00000008, 0, 0, 0, 0);
        $SendMouseEvent::mouse_event(0x00000010, 0, 0, 0, 0);
    }
    if($Button -eq "MiddleClick")
    {
        $SendMouseEvent::mouse_event(0x00000020, 0, 0, 0, 0);
        $SendMouseEvent::mouse_event(0x00000040, 0, 0, 0, 0);
    }
    if($Button -eq "Wheel")
    {
        $SendMouseEvent::mouse_event(0x00000800, 0, 0, $delta, 0);
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

    $reader = @('AcroRd32', 'Acrobat')

    Start-Sleep -Milliseconds 200

    If ($p=Get-Process -Name $reader -ErrorAction SilentlyContinue) {
        $p | Stop-Process -Force
    }
}

Function Wait-AcrobatReader {
    [CmdletBinding()]
    Param(
        [timespan]$TimeOut=[timespan]::FromSeconds(10)
    )

    $reader = @('AcroRd32', 'Acrobat')
    $Starttime = Get-Date
    While ($null -eq (Get-Process -Name $reader -EA SilentlyContinue) -and
           ((Get-Date)-$StartTime -le $TimeOut)) {
        Start-Sleep -Milliseconds 200
    }
}

Function Wait-FileAvailable {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,Position=0)]
        [string]$File,
        [timespan]$TimeOut=[timespan]::FromSeconds(120)
    )

    $Starttime = Get-Date
    While (-Not (Test-Path $File) -and
           ((Get-Date)-$StartTime -le $TimeOut)) {
        Start-Sleep -Milliseconds 200
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