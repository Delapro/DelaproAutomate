# DLPAutoCommon.PS1

# benötigt .Net Framework 4.8
# TODO: auf PS7 testen

Function Initialize-Automation {

    Add-Type -AssemblyName System.Windows.Forms
    [void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
    [void] [System.Reflection.Assembly]::LoadWithPartialName("'System.Drawing")
    Add-Type -AssemblyName System.Speech

    $global:DlpAutoSelectAppSleep = 100
    $global:DlpAutoSendKeySleep = 10
    $global:DlpAutoApp = 'Delapro'
    $global:DlpAutoMainIni = 'C:\Delapro\DLP_MAIN.INI'
    $global:DlpAutoTuiRows = 25
    $global:DlpAutoTuiColumns = 80

}

# Liest einen Wert aus der DLP_MAIN.INI. Die Funktion ist bewusst einfach
# gehalten, damit keine zusätzlichen Module oder COM-Objekte benötigt werden.
Function Get-DLPMainIniValue {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [String]$Section,
        [Parameter(Mandatory)]
        [String]$Key,
        [String]$DefaultValue,
        [String]$IniPath=$global:DlpAutoMainIni
    )

    If (-Not ($IniPath)) {
        $IniPath = 'C:\Delapro\DLP_MAIN.INI'
    }

    If (-Not (Test-Path -LiteralPath $IniPath -PathType Leaf)) {
        Write-Verbose "DLP_MAIN.INI nicht gefunden: $IniPath"
        Return $DefaultValue
    }

    $CurrentSection = ''
    foreach ($Line in (Get-Content -LiteralPath $IniPath -ErrorAction Stop)) {
        $TrimmedLine = $Line.Trim()

        If ((-Not ($TrimmedLine)) -or $TrimmedLine.StartsWith(';') -or $TrimmedLine.StartsWith('#')) {
            Continue
        }

        If ($TrimmedLine -match '^\[(?<Section>[^\]]+)\]$') {
            $CurrentSection = $Matches.Section.Trim()
            Continue
        }

        If (($CurrentSection -ieq $Section) -and ($TrimmedLine -match '^(?<Key>[^=]+?)\s*=\s*(?<Value>.*)$')) {
            If ($Matches.Key.Trim() -ieq $Key) {
                Return $Matches.Value.Trim().Trim('"')
            }
        }
    }

    $DefaultValue
}

# Prüft den Schalter [Modus] BehandlerModulAktiv in der DLP_MAIN.INI.
Function Test-DLPBehandlerModulAktiv {
    [CmdletBinding()]
    Param(
        [String]$IniPath=$global:DlpAutoMainIni
    )

    (Get-DLPMainIniValue -Section 'Modus' -Key 'BehandlerModulAktiv' -DefaultValue '0' -IniPath $IniPath) -eq '1'
}

# Führt eine optionale Aktion in einem definierten Maskenzustand aus.
# Der Codeblock erhält ein Kontextobjekt mit Modul, Zustand und Daten.
Function Invoke-DLPStateAction {
    [CmdletBinding()]
    Param(
        [ScriptBlock]$Action,
        [Parameter(Mandatory)]
        [String]$Module,
        [Parameter(Mandatory)]
        [String]$State,
        [Hashtable]$Data=@{}
    )

    If ($Action) {
        $Context = [PSCustomObject]@{
            Module = $Module
            State = $State
            Data = [PSCustomObject]$Data
        }
        & $Action $Context
    }
}

# Verlässt eine Eingabemaske. -Save darf nur verwendet werden, wenn F10
# in der aktuellen Maske tatsächlich "Speichern" bedeutet.
Function Exit-DLPInputMask {
    [CmdletBinding()]
    Param(
        [Switch]$Save,
        [String]$App=$global:DlpAutoApp
    )

    If (Select-App -App $App) {
        If ($Save) {
            Send-Key -Keys "{F10}"
        } else {
            Send-Key -Keys "{ESC}"
        }
    }
}

# Funktioniert nicht bei Consolen-Fenstern!!!
Function Select-App {
    [CmdletBinding()]
    Param(
        [Parameter(ParameterSetName='title', Position=0)]
        [ValidateNotNullOrEmpty()]
        [String]$App=$global:DlpAutoApp,
	[Parameter(ParameterSetName='process', Position=0)]
        [ValidateNotNullOrEmpty()]
        [int]$ProcessID
	)

	switch -exact ($PSCmdlet.ParameterSetName) {
	    { @('title') -contains $_} {
                        If (Get-Process|where MainWindowTitle -eq $App) {
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

# Direkte Variante Tastendrücke zuzuordnen, z. B. auch Windows-Taste, 
# Beispiel: Send-VirtKey -Key X oder Send-VirtKey -Key R
Function Send-VirtKey {
	[CmdletBinding()]
	Param($Key)	# $Key sollte Großbuchstabe sein

	# siehe auch: https://github.com/asweigart/pyautogui,
	#             https://github.com/learncodebygaming/pydirectinput
	
if (-not ([System.Management.Automation.PSTypeName]'KeyboardSend').Type) {
  $source = @"
	using System;
	using System.Collections.Generic;
	using System.Linq;
	using System.Text;
	using System.Threading.Tasks;
	using System.Runtime.InteropServices;
	using System.Windows.Forms;
	namespace KeyboardSend
	{
	    public class KeyboardSend
	    {
		[DllImport("user32.dll")]
		public static extern void keybd_event(byte bVk, byte bScan, int dwFlags, int dwExtraInfo);
		private const int KEYEVENTF_EXTENDEDKEY = 1;
		private const int KEYEVENTF_KEYUP = 2;

		private const int VK_STARTKEY = 0x5B;
		private const int VK_ESCAPE = 0x1B;
		private const int KEYEVENTF_KEYDOWN = 0x0;

		public static void KeyDown(Keys vKey)
		{
		    keybd_event((byte)vKey, 0, KEYEVENTF_EXTENDEDKEY, 0);
		}
		public static void KeyUp(Keys vKey)
		{
		    keybd_event((byte)vKey, 0, KEYEVENTF_EXTENDEDKEY | KEYEVENTF_KEYUP, 0);
		}
	    }
	}
"@

  Add-Type -TypeDefinition $source -ReferencedAssemblies "System.Windows.Forms"
}

	[KeyboardSend.KeyboardSend]::KeyDown("LWin")
	[KeyboardSend.KeyboardSend]::KeyDown("$Key")
	[KeyboardSend.KeyboardSend]::KeyUp("LWin")
}

# Lädt die für Fensterkoordinaten, Bildschirmkopien und Mausaktionen
# benötigten Win32-Funktionen genau einmal.
Function Initialize-DLPWindowApi {

    If (-Not ([System.Management.Automation.PSTypeName]'DLPWindowApi').Type) {
        Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public static class DLPWindowApi
{
    [StructLayout(LayoutKind.Sequential)]
    public struct RECT
    {
        public int Left;
        public int Top;
        public int Right;
        public int Bottom;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct POINT
    {
        public int X;
        public int Y;
    }

    [DllImport("user32.dll", SetLastError=true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

    [DllImport("user32.dll", SetLastError=true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool GetClientRect(IntPtr hWnd, out RECT lpRect);

    [DllImport("user32.dll", SetLastError=true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool ClientToScreen(IntPtr hWnd, ref POINT lpPoint);

    [DllImport("user32.dll", CharSet=CharSet.Auto, CallingConvention=CallingConvention.StdCall)]
    public static extern void mouse_event(uint dwFlags, uint dx, uint dy, int dwData, UIntPtr dwExtraInfo);
}
"@
    }
}

# Liefert das Hauptfensterhandle einer Anwendung.
Function Get-DLPWindowHandle {
    [CmdletBinding(DefaultParameterSetName='title')]
    Param(
        [Parameter(ParameterSetName='title')]
        [ValidateNotNullOrEmpty()]
        [String]$App=$global:DlpAutoApp,
        [Parameter(ParameterSetName='process', Mandatory=$true)]
        [ValidateRange(1, [Int32]::MaxValue)]
        [Int]$ProcessID
    )

    If ($PSCmdlet.ParameterSetName -eq 'process') {
        $Process = Get-Process -Id $ProcessID -ErrorAction Stop
    } else {
        $Process = Get-Process | Where-Object {
            ($_.MainWindowTitle -eq $App) -and ($_.MainWindowHandle -ne 0)
        } | Select-Object -First 1
    }
 
    If (($null -eq $Process) -or ($Process.MainWindowHandle -eq 0)) {
        throw 'Das Fenster der Anwendung wurde nicht gefunden.'
    }

    [IntPtr]$Process.MainWindowHandle
}

# Liefert den Fenster- oder Clientbereich in absoluten Bildschirmkoordinaten.
Function Get-DLPWindowRectangle {
    [CmdletBinding(DefaultParameterSetName='title')]
    Param(
        [ValidateSet('Client', 'Window')]
        [String]$Area='Client',
        [Parameter(ParameterSetName='title')]
        [ValidateNotNullOrEmpty()]
        [String]$App=$global:DlpAutoApp,
        [Parameter(ParameterSetName='process', Mandatory=$true)]
        [ValidateRange(1, [Int32]::MaxValue)]
        [Int]$ProcessID
    )

    Initialize-DLPWindowApi

    If ($PSCmdlet.ParameterSetName -eq 'process') {
        $WindowHandle = Get-DLPWindowHandle -ProcessID $ProcessID
    } else {
        $WindowHandle = Get-DLPWindowHandle -App $App
    }

    $Rectangle = New-Object DLPWindowApi+RECT

    If ($Area -eq 'Window') {
        If (-Not ([DLPWindowApi]::GetWindowRect($WindowHandle, [ref]$Rectangle))) {
            throw 'Der Fensterbereich konnte nicht ermittelt werden.'
        }

        Return (New-Object System.Drawing.Rectangle -ArgumentList @(
            $Rectangle.Left,
            $Rectangle.Top,
            ($Rectangle.Right - $Rectangle.Left),
            ($Rectangle.Bottom - $Rectangle.Top)
        ))
    }

    If (-Not ([DLPWindowApi]::GetClientRect($WindowHandle, [ref]$Rectangle))) {
        throw 'Der Clientbereich konnte nicht ermittelt werden.'
    }
    $ClientOrigin = New-Object DLPWindowApi+POINT
    $ClientOrigin.X = 0
    $ClientOrigin.Y = 0

    If (-Not ([DLPWindowApi]::ClientToScreen($WindowHandle, [ref]$ClientOrigin))) {
        throw 'Der Clientbereich konnte nicht in Bildschirmkoordinaten umgerechnet werden.'
    }
 
    New-Object System.Drawing.Rectangle -ArgumentList @(
        $ClientOrigin.X,
        $ClientOrigin.Y,
        ($Rectangle.Right - $Rectangle.Left),
        ($Rectangle.Bottom - $Rectangle.Top)
    )
}

# Behält die bisherige absolute Bildschirmpositionierung für bestehende Skripte bei.
Function Set-MousePosition {
    [CmdletBinding()]
    Param(
        [Int]$XPos,
        [Int]$YPos
    )

    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($XPos, $YPos)
}

# Positioniert die Maus relativ zum Clientbereich des Delapro-Fensters.
Function Set-DLPClientMousePosition {
    [CmdletBinding(DefaultParameterSetName='title')]
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateRange(0, [Int32]::MaxValue)]
        [Int]$ClientX,
        [Parameter(Mandatory=$true)]
        [ValidateRange(0, [Int32]::MaxValue)]
        [Int]$ClientY,
        [Parameter(ParameterSetName='title')]
        [String]$App=$global:DlpAutoApp,
        [Parameter(ParameterSetName='process', Mandatory=$true)]
        [Int]$ProcessID
    )

    If ($PSCmdlet.ParameterSetName -eq 'process') {
        $ClientRectangle = Get-DLPWindowRectangle -Area Client -ProcessID $ProcessID
    } else {
        $ClientRectangle = Get-DLPWindowRectangle -Area Client -App $App
    }

    If (($ClientX -ge $ClientRectangle.Width) -or ($ClientY -ge $ClientRectangle.Height)) {
        throw 'Die gewünschte Position liegt außerhalb des Clientbereichs.'
    }

    Set-MousePosition -XPos ($ClientRectangle.X + $ClientX) -YPos ($ClientRectangle.Y + $ClientY)
}

Function Invoke-MouseEvent {
    [CmdletBinding()]
    Param(
        [ValidateSet('LeftClick', 'RightClick', 'MiddleClick', 'Wheel')]
        [String]$Button='LeftClick',
        [Int]$Delta
    )

    Initialize-DLPWindowApi

    Switch ($Button) {
        'LeftClick' {
            [DLPWindowApi]::mouse_event(0x00000002, 0, 0, 0, [UIntPtr]::Zero)
            [DLPWindowApi]::mouse_event(0x00000004, 0, 0, 0, [UIntPtr]::Zero)
        }
        'RightClick' {
            [DLPWindowApi]::mouse_event(0x00000008, 0, 0, 0, [UIntPtr]::Zero)
            [DLPWindowApi]::mouse_event(0x00000010, 0, 0, 0, [UIntPtr]::Zero)
        }
        'MiddleClick' {
            [DLPWindowApi]::mouse_event(0x00000020, 0, 0, 0, [UIntPtr]::Zero)
            [DLPWindowApi]::mouse_event(0x00000040, 0, 0, 0, [UIntPtr]::Zero)
        }
        'Wheel' {
            [DLPWindowApi]::mouse_event(0x00000800, 0, 0, $Delta, [UIntPtr]::Zero)
        }
    }
}

# Ermittelt die aktuelle Zellgröße eines festen TUI-Rasters im Clientbereich.
Function Get-DLPTuiGridMetrics {
    [CmdletBinding(DefaultParameterSetName='title')]
    Param(
        [ValidateRange(1, 1000)]
        [Int]$Rows=$global:DlpAutoTuiRows,
        [ValidateRange(1, 1000)]
        [Int]$Columns=$global:DlpAutoTuiColumns,
        [ValidateRange(0, [Int32]::MaxValue)]
        [Int]$PaddingLeft=0,
        [ValidateRange(0, [Int32]::MaxValue)]
        [Int]$PaddingTop=0,
        [ValidateRange(0, [Int32]::MaxValue)]
        [Int]$PaddingRight=0,
        [ValidateRange(0, [Int32]::MaxValue)]
        [Int]$PaddingBottom=0,
        [Parameter(ParameterSetName='title')]
        [String]$App=$global:DlpAutoApp,
        [Parameter(ParameterSetName='process', Mandatory=$true)]
        [Int]$ProcessID
    )

    If ($PSCmdlet.ParameterSetName -eq 'process') {
        $ClientRectangle = Get-DLPWindowRectangle -Area Client -ProcessID $ProcessID
    } else {
        $ClientRectangle = Get-DLPWindowRectangle -Area Client -App $App
    }

    $UsableWidth = $ClientRectangle.Width - $PaddingLeft - $PaddingRight
    $UsableHeight = $ClientRectangle.Height - $PaddingTop - $PaddingBottom

    If (($UsableWidth -le 0) -or ($UsableHeight -le 0)) {
        throw 'Die Randangaben lassen keinen nutzbaren TUI-Bereich übrig.'
    }

    [PSCustomObject]@{
        Rows = $Rows
        Columns = $Columns
        ClientRectangle = $ClientRectangle
        OriginX = $ClientRectangle.X + $PaddingLeft
        OriginY = $ClientRectangle.Y + $PaddingTop
        Width = $UsableWidth
        Height = $UsableHeight
        CellWidth = $UsableWidth / [Double]$Columns
        CellHeight = $UsableHeight / [Double]$Rows
   }
}

# Rechnet eine 1-basierte TUI-Zeile und -Spalte in Bildschirmkoordinaten um.
Function Get-DLPTuiCellPoint {
    [CmdletBinding(DefaultParameterSetName='title')]
    Param(
        [Parameter(Mandatory=$true)]
        [ValidateRange(1, 1000)]
        [Int]$Row,
        [Parameter(Mandatory=$true)]
        [ValidateRange(1, 1000)]
        [Int]$Column,
        [ValidateRange(1, 1000)]
        [Int]$Rows=$global:DlpAutoTuiRows,
        [ValidateRange(1, 1000)]
        [Int]$Columns=$global:DlpAutoTuiColumns,
        [Int]$PaddingLeft=0,
        [Int]$PaddingTop=0,
        [Int]$PaddingRight=0,
        [Int]$PaddingBottom=0,
        [Parameter(ParameterSetName='title')]
        [String]$App=$global:DlpAutoApp,
        [Parameter(ParameterSetName='process', Mandatory=$true)]
        [Int]$ProcessID
    )

    If (($Row -gt $Rows) -or ($Column -gt $Columns)) {
        throw 'Die gewünschte TUI-Zelle liegt außerhalb des angegebenen Rasters.'
    }

    $MetricParameter = @{
        Rows = $Rows
        Columns = $Columns
        PaddingLeft = $PaddingLeft
        PaddingTop = $PaddingTop
        PaddingRight = $PaddingRight
        PaddingBottom = $PaddingBottom
    }

    If ($PSCmdlet.ParameterSetName -eq 'process') {
        $MetricParameter.ProcessID = $ProcessID
    } else {
        $MetricParameter.App = $App
    }

    $Metrics = Get-DLPTuiGridMetrics @MetricParameter

    [PSCustomObject]@{
        Row = $Row
        Column = $Column
        X = [Int][Math]::Round($Metrics.OriginX + (($Column - 0.5) * $Metrics.CellWidth))
        Y = [Int][Math]::Round($Metrics.OriginY + (($Row - 0.5) * $Metrics.CellHeight))
        CellWidth = $Metrics.CellWidth
        CellHeight = $Metrics.CellHeight
        ClientRectangle = $Metrics.ClientRectangle
    }
}

Function Set-DLPTuiMousePosition {
    [CmdletBinding(DefaultParameterSetName='title')]
    Param(
        [Parameter(Mandatory=$true)]
        [Int]$Row,
        [Parameter(Mandatory=$true)]
        [Int]$Column,
        [Int]$Rows=$global:DlpAutoTuiRows,
        [Int]$Columns=$global:DlpAutoTuiColumns,
        [Int]$PaddingLeft=0,
        [Int]$PaddingTop=0,
        [Int]$PaddingRight=0,
        [Int]$PaddingBottom=0,
        [Parameter(ParameterSetName='title')]
        [String]$App=$global:DlpAutoApp,
        [Parameter(ParameterSetName='process', Mandatory=$true)]
        [Int]$ProcessID
    )

    $PointParameter = @{
        Row = $Row
        Column = $Column
        Rows = $Rows
        Columns = $Columns
        PaddingLeft = $PaddingLeft
        PaddingTop = $PaddingTop
        PaddingRight = $PaddingRight
        PaddingBottom = $PaddingBottom
    }

    If ($PSCmdlet.ParameterSetName -eq 'process') {
        $PointParameter.ProcessID = $ProcessID
    } else {
        $PointParameter.App = $App
    }

    $Point = Get-DLPTuiCellPoint @PointParameter
    Set-MousePosition -XPos $Point.X -YPos $Point.Y
    $Point
}

Function Invoke-DLPTuiClick {
    [CmdletBinding(DefaultParameterSetName='title')]
    Param(
        [Parameter(Mandatory=$true)]
        [Int]$Row,
        [Parameter(Mandatory=$true)]
        [Int]$Column,
        [Int]$Rows=$global:DlpAutoTuiRows,
        [Int]$Columns=$global:DlpAutoTuiColumns,
        [Int]$PaddingLeft=0,
        [Int]$PaddingTop=0,
        [Int]$PaddingRight=0,
        [Int]$PaddingBottom=0,
        [ValidateSet('LeftClick', 'RightClick', 'MiddleClick')]
        [String]$Button='LeftClick',
        [Int]$DelayMilliseconds=100,
        [Parameter(ParameterSetName='title')]
        [String]$App=$global:DlpAutoApp,
        [Parameter(ParameterSetName='process', Mandatory=$true)]
        [Int]$ProcessID
    )

    If ($PSCmdlet.ParameterSetName -eq 'process') {
        If (-Not (Select-App -ProcessID $ProcessID)) {
            throw 'Die Anwendung konnte nicht aktiviert werden.'
        }
        $Point = Set-DLPTuiMousePosition -Row $Row -Column $Column -Rows $Rows -Columns $Columns `
            -PaddingLeft $PaddingLeft -PaddingTop $PaddingTop -PaddingRight $PaddingRight `
            -PaddingBottom $PaddingBottom -ProcessID $ProcessID
    } else {
        If (-Not (Select-App -App $App)) {
            throw 'Die Anwendung konnte nicht aktiviert werden.'
        }
        $Point = Set-DLPTuiMousePosition -Row $Row -Column $Column -Rows $Rows -Columns $Columns `
            -PaddingLeft $PaddingLeft -PaddingTop $PaddingTop -PaddingRight $PaddingRight `
            -PaddingBottom $PaddingBottom -App $App
    }

    If ($DelayMilliseconds -gt 0) {
        Start-Sleep -Milliseconds $DelayMilliseconds
    }

    Invoke-MouseEvent -Button $Button
    $Point
}

# Kopiert einen beliebigen Bereich des sichtbaren Bildschirms.
# Width und Height sind Ausdehnungen und keine rechten/unteren Koordinaten.
Function Copy-Screen {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [Int]$X,
        [Parameter(Mandatory=$true)]
        [Int]$Y,
        [Parameter(Mandatory=$true)]
        [ValidateRange(1, [Int32]::MaxValue)]
        [Int]$Width,
        [Parameter(Mandatory=$true)]
        [ValidateRange(1, [Int32]::MaxValue)]
        [Int]$Height,
        [String]$Path=((New-TemporaryFile).FullName.Replace('.tmp', '.png'))
    )

    $Directory = Split-Path -Parent $Path
    If ($Directory -and (-Not (Test-Path -LiteralPath $Directory -PathType Container))) {
        New-Item -ItemType Directory -Path $Directory -Force | Out-Null
    }

    $Bounds = New-Object System.Drawing.Rectangle -ArgumentList $X, $Y, $Width, $Height
    $Bitmap = New-Object System.Drawing.Bitmap -ArgumentList $Bounds.Width, $Bounds.Height
    $Graphics = [System.Drawing.Graphics]::FromImage($Bitmap)

    try {
        $Graphics.CopyFromScreen($Bounds.Location.X, $Bounds.Location.Y, 0, 0, $Bounds.Size)
        $Bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally {
        $Graphics.Dispose()
        $Bitmap.Dispose()
    }

    $Path
}

# Kopiert einen Ausschnitt relativ zum Clientbereich des Delapro-Fensters.
Function Copy-DLPClientArea {
    [CmdletBinding(DefaultParameterSetName='title')]
    Param(
        [Parameter(Mandatory=$true)]
        [Int]$X,
        [Parameter(Mandatory=$true)]
        [Int]$Y,
        [Parameter(Mandatory=$true)]
        [Int]$Width,
        [Parameter(Mandatory=$true)]
        [Int]$Height,
        [String]$Path=((New-TemporaryFile).FullName.Replace('.tmp', '.png')),
        [Int]$DelayMilliseconds=200,
        [Parameter(ParameterSetName='title')]
        [String]$App=$global:DlpAutoApp,
        [Parameter(ParameterSetName='process', Mandatory=$true)]
        [Int]$ProcessID
    )

    If ($PSCmdlet.ParameterSetName -eq 'process') {
        If (-Not (Select-App -ProcessID $ProcessID)) {
            throw 'Die Anwendung konnte nicht aktiviert werden.'
        }
        $ClientRectangle = Get-DLPWindowRectangle -Area Client -ProcessID $ProcessID
    } else {
        If (-Not (Select-App -App $App)) {
            throw 'Die Anwendung konnte nicht aktiviert werden.'
        }
        $ClientRectangle = Get-DLPWindowRectangle -Area Client -App $App
    }

    If ($DelayMilliseconds -gt 0) {
        Start-Sleep -Milliseconds $DelayMilliseconds
    }

    If (($X -lt 0) -or ($Y -lt 0) -or (($X + $Width) -gt $ClientRectangle.Width) -or
        (($Y + $Height) -gt $ClientRectangle.Height)) {
        throw 'Der gewünschte Ausschnitt liegt außerhalb des Clientbereichs.'
    }

    Copy-Screen -X ($ClientRectangle.X + $X) -Y ($ClientRectangle.Y + $Y) `
        -Width $Width -Height $Height -Path $Path
}

# Kopiert einen durch TUI-Zeilen und -Spalten beschriebenen Ausschnitt.
Function Copy-DLPTuiArea {
    [CmdletBinding(DefaultParameterSetName='title')]
    Param(
        [Parameter(Mandatory=$true)]
        [Int]$StartRow,
        [Parameter(Mandatory=$true)]
        [Int]$StartColumn,
        [Parameter(Mandatory=$true)]
        [Int]$EndRow,
        [Parameter(Mandatory=$true)]
        [Int]$EndColumn,
        [Int]$Rows=$global:DlpAutoTuiRows,
        [Int]$Columns=$global:DlpAutoTuiColumns,
        [Int]$PaddingLeft=0,
        [Int]$PaddingTop=0,
        [Int]$PaddingRight=0,
        [Int]$PaddingBottom=0,
        [String]$Path=((New-TemporaryFile).FullName.Replace('.tmp', '.png')),
        [Int]$DelayMilliseconds=200,
        [Parameter(ParameterSetName='title')]
        [String]$App=$global:DlpAutoApp,
        [Parameter(ParameterSetName='process', Mandatory=$true)]
        [Int]$ProcessID
    )

    If (($StartRow -lt 1) -or ($StartColumn -lt 1) -or
        ($EndRow -lt $StartRow) -or ($EndColumn -lt $StartColumn) -or
        ($EndRow -gt $Rows) -or ($EndColumn -gt $Columns)) {
        throw 'Der gewünschte TUI-Ausschnitt ist ungültig.'
    }

    $MetricParameter = @{
        Rows = $Rows
        Columns = $Columns
        PaddingLeft = $PaddingLeft
        PaddingTop = $PaddingTop
        PaddingRight = $PaddingRight
        PaddingBottom = $PaddingBottom
    }

    If ($PSCmdlet.ParameterSetName -eq 'process') {
        If (-Not (Select-App -ProcessID $ProcessID)) {
            throw 'Die Anwendung konnte nicht aktiviert werden.'
        }
        $MetricParameter.ProcessID = $ProcessID
    } else {
        If (-Not (Select-App -App $App)) {
            throw 'Die Anwendung konnte nicht aktiviert werden.'
        }
        $MetricParameter.App = $App
    }

    If ($DelayMilliseconds -gt 0) {
        Start-Sleep -Milliseconds $DelayMilliseconds
    }

    $Metrics = Get-DLPTuiGridMetrics @MetricParameter
    $X = [Int][Math]::Floor($Metrics.OriginX + (($StartColumn - 1) * $Metrics.CellWidth))
    $Y = [Int][Math]::Floor($Metrics.OriginY + (($StartRow - 1) * $Metrics.CellHeight))
    $Right = [Int][Math]::Ceiling($Metrics.OriginX + ($EndColumn * $Metrics.CellWidth))
    $Bottom = [Int][Math]::Ceiling($Metrics.OriginY + ($EndRow * $Metrics.CellHeight))

    Copy-Screen -X $X -Y $Y -Width ($Right - $X) -Height ($Bottom - $Y) -Path $Path
}

# Speichert das aktive Fenster. Standardmäßig bleibt aus Gründen der
# Rückwärtskompatibilität der Windows-Rahmen enthalten.
Function Save-ActiveWindow {
    [CmdletBinding(DefaultParameterSetName='title')]
    Param(
        [String]$Path=((New-TemporaryFile).FullName.Replace('.tmp', '.png')),
        [ValidateSet('Client', 'Window')]
        [String]$CaptureArea='Window',
        [Int]$DelayMilliseconds=200,
        [Parameter(ParameterSetName='title')]
        [String]$App=$global:DlpAutoApp,
        [Parameter(ParameterSetName='process', Mandatory=$true)]
        [Int]$ProcessID
    )

    If ($PSCmdlet.ParameterSetName -eq 'process') {
        If (-Not (Select-App -ProcessID $ProcessID)) {
            throw 'Die Anwendung konnte nicht aktiviert werden.'
        }
    } else {
        If (-Not (Select-App -App $App)) {
            throw 'Die Anwendung konnte nicht aktiviert werden.'
        }
    }

    If ($DelayMilliseconds -gt 0) {
        Start-Sleep -Milliseconds $DelayMilliseconds
    }

    If ($PSCmdlet.ParameterSetName -eq 'process') {
        $Bounds = Get-DLPWindowRectangle -Area $CaptureArea -ProcessID $ProcessID
    } else {
        $Bounds = Get-DLPWindowRectangle -Area $CaptureArea -App $App
    }

    Copy-Screen -X $Bounds.X -Y $Bounds.Y -Width $Bounds.Width -Height $Bounds.Height -Path $Path
}

# Dokumentationsbilder enthalten standardmäßig nur den Clientbereich.
# Mit -CaptureArea Window kann weiterhin der komplette Windows-Rahmen
# aufgenommen werden.
Function Save-DLPDocumentationWindow {
    [CmdletBinding(DefaultParameterSetName='title')]
    Param(
        [Parameter(Mandatory=$true)]
        [String]$Path,
        [ValidateSet('Client', 'Window')]
        [String]$CaptureArea='Client',
        [Int]$DelayMilliseconds=300,
        [Parameter(ParameterSetName='title')]
        [String]$App=$global:DlpAutoApp,
        [Parameter(ParameterSetName='process', Mandatory=$true)]
        [Int]$ProcessID
    )

    If ($PSCmdlet.ParameterSetName -eq 'process') {
        Save-ActiveWindow -Path $Path -CaptureArea $CaptureArea `
            -DelayMilliseconds $DelayMilliseconds -ProcessID $ProcessID
    } else {
        Save-ActiveWindow -Path $Path -CaptureArea $CaptureArea `
            -DelayMilliseconds $DelayMilliseconds -App $App
    }
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
        [Switch]$Async
    )

    $voice = New-Object System.Speech.Synthesis.SpeechSynthesizer
    If ($Async) {
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

Function TextBandEinblendung {
        # auf Basis von https://learn-powershell.net/2012/10/14/powershell-and-wpf-writing-data-to-a-ui-from-a-different-runspace/

    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName System.Windows.Forms

    $syncHash = [hashtable]::Synchronized(@{})
    $newRunspace =[runspacefactory]::CreateRunspace()
    $newRunspace.ApartmentState = "STA"
    $newRunspace.ThreadOptions = "ReuseThread"         
    $newRunspace.Open()
    $newRunspace.SessionStateProxy.SetVariable("syncHash",$syncHash)          
    $psCmd = [PowerShell]::Create().AddScript({   
        [xml]$xaml = @"
    <Window x:Class="WpfApp5.MainWindow"
            xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
            xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
            xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
            xmlns:local="clr-namespace:WpfApp5"
            Title="MainWindow" Height="100" Width="800" WindowStyle="None"
        Opacity="0.7" ResizeMode="NoResize" Background="Gray"
            ShowInTaskbar="False" Topmost="True"
        AllowsTransparency="True"  >
        <Grid>
        <StackPanel Orientation="Vertical">
            <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
            <TextBlock x:Name="textblock"  Text="Hallo"  FontSize="20" Foreground="White" HorizontalAlignment="Center"/>
            <TextBlock x:Name="textblock2" Text="Hallo2" FontSize="20" Foreground="White" HorizontalAlignment="Center"/>
            </StackPanel>
        </StackPanel>
        </Grid>
    </Window>
"@
    
    $XAML.Window.RemoveAttribute("x:Class")
        $reader=(New-Object System.Xml.XmlNodeReader $xaml)
        $syncHash.Window=[Windows.Markup.XamlReader]::Load( $reader )
        $syncHash.TextBlock = $syncHash.window.FindName("textblock")
        $syncHash.Window.ShowDialog() | Out-Null
        $syncHash.Error = $Error
    })
    $psCmd.Runspace = $newRunspace
    $data = $psCmd.BeginInvoke()

    Start-Sleep -milliseconds 200
    $syncHash.Window.Dispatcher.invoke(
        [action]{$syncHash.Window.Background='Black'},
        "Normal"
    )

    Start-Sleep -milliseconds 500
    $syncHash.Window.Dispatcher.invoke(
        [action]{$syncHash.TextBlock.Text="Das ist ein längerer Text"},
        "Normal"
    )


function Get-ChildWindow{
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true, ValueFromPipelinebyPropertyName = $true)]
        [ValidateNotNullorEmpty()]
        [System.IntPtr]$MainWindowHandle
    )
    
    BEGIN{
        function Get-WindowName($hwnd) {
            $len = [apifuncs]::GetWindowTextLength($hwnd)
            if($len -gt 0){
                $sb = New-Object text.stringbuilder -ArgumentList ($len + 1)
                $rtnlen = [apifuncs]::GetWindowText($hwnd,$sb,$sb.Capacity)
                $sb.tostring()
            }
        }
    
        if (("APIFuncs" -as [type]) -eq $null){
            Add-Type  @"
            using System;
            using System.Runtime.InteropServices;
            using System.Collections.Generic;
            using System.Text;
            public class APIFuncs
              {
                [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
                public static extern bool GetWindowRect(HandleRef hWnd, out RECT lpRect);
                
                public struct RECT
                {
                    public int Left;        // x position of upper-left corner
                    public int Top;         // y position of upper-left corner
                    public int Right;       // x position of lower-right corner
                    public int Bottom;      // y position of lower-right corner
                }
                
                [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
                public static extern int GetWindowText(IntPtr hwnd,StringBuilder lpString, int cch);
    
                [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)]
                public static extern IntPtr GetForegroundWindow();
    
                [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)]
                public static extern Int32 GetWindowThreadProcessId(IntPtr hWnd,out Int32 lpdwProcessId);
    
                [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)]
                public static extern Int32 GetWindowTextLength(IntPtr hWnd);
    
                [DllImport("user32")]
                [return: MarshalAs(UnmanagedType.Bool)]
                public static extern bool EnumChildWindows(IntPtr window, EnumWindowProc callback, IntPtr i);
                public static List<IntPtr> GetChildWindows(IntPtr parent)
                {
                   List<IntPtr> result = new List<IntPtr>();
                   GCHandle listHandle = GCHandle.Alloc(result);
                   try
                   {
                       EnumWindowProc childProc = new EnumWindowProc(EnumWindow);
                       EnumChildWindows(parent, childProc,GCHandle.ToIntPtr(listHandle));
                   }
                   finally
                   {
                       if (listHandle.IsAllocated)
                           listHandle.Free();
                   }
                   return result;
               }
                private static bool EnumWindow(IntPtr handle, IntPtr pointer)
               {
                   GCHandle gch = GCHandle.FromIntPtr(pointer);
                   List<IntPtr> list = gch.Target as List<IntPtr>;
                   if (list == null)
                   {
                       throw new InvalidCastException("GCHandle Target could not be cast as List<IntPtr>");
                   }
                   list.Add(handle);
                   //  You can modify this to check to see if you want to cancel the operation, then return a null here
                   return true;
               }
                public delegate bool EnumWindowProc(IntPtr hWnd, IntPtr parameter);
               }
"@
            }
    }
    
    PROCESS{
        foreach ($child in ([apifuncs]::GetChildWindows($MainWindowHandle))){
            Write-Output (,([PSCustomObject] @{
                MainWindowHandle = $MainWindowHandle
                ChildId = $child
                ChildTitle = (Get-WindowName($child))
            }))
        }

        # muss noch ausgelagert werden, aber dann geht wieder apifuncs verloren!
        $phandle = [apifuncs]::GetForegroundWindow()            
                
        $o = New-Object -TypeName System.Object            
        $href = New-Object -TypeName System.RunTime.InteropServices.HandleRef -ArgumentList $o, $phandle            
                    
        $rct = New-Object apifuncs+RECT            
                    
        [apifuncs]::GetWindowRect($href, [ref]$rct)  
    
        
    }
    }
}

