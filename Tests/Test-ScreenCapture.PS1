[CmdletBinding()]
Param(
    [String]$OutputDirectory=(Join-Path $PSScriptRoot 'ScreenCaptureResults')
)

$ErrorActionPreference = 'Stop'
$RepositoryRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $RepositoryRoot 'DLPAutoCommon.PS1')
Initialize-Automation

New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
$OutputDirectory = (Resolve-Path -LiteralPath $OutputDirectory).Path
$WindowTitle = 'DLP Capture Test ' + [Guid]::NewGuid().ToString('N')
$HelperPath = Join-Path ([System.IO.Path]::GetTempPath()) ("DlpCaptureWindow-" + [Guid]::NewGuid().ToString('N') + '.ps1')

$HelperContent = @'
Param([String]$Title)
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$Form = New-Object System.Windows.Forms.Form
$Form.Text = $Title
$Form.StartPosition = 'Manual'
$Form.Location = New-Object System.Drawing.Point -ArgumentList 100, 100
$Form.ClientSize = New-Object System.Drawing.Size -ArgumentList 640, 400
$Form.FormBorderStyle = 'FixedSingle'
$Form.MaximizeBox = $false
$Form.MinimizeBox = $false
$Form.BackColor = [System.Drawing.Color]::FromArgb(17, 123, 231)
$Label = New-Object System.Windows.Forms.Label
$Label.Text = 'DelaproAutomate Bildschirmtest'
$Label.AutoSize = $true
$Label.Location = New-Object System.Drawing.Point -ArgumentList 20, 20
$Label.ForeColor = [System.Drawing.Color]::White
$Form.Controls.Add($Label)
[System.Windows.Forms.Application]::Run($Form)
'@
Set-Content -LiteralPath $HelperPath -Value $HelperContent -Encoding UTF8

$Process = $null
try {
    $PowerShellExe = Join-Path $PSHOME 'powershell.exe'
    If (-Not (Test-Path -LiteralPath $PowerShellExe)) {
        $PowerShellExe = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
    }
    $Process = Start-Process -FilePath $PowerShellExe -ArgumentList @(
        '-NoProfile', '-STA', '-ExecutionPolicy', 'Bypass', '-File', "`"$HelperPath`"", '-Title', "`"$WindowTitle`""
    ) -PassThru

    $Deadline = (Get-Date).AddSeconds(20)
    do {
        Start-Sleep -Milliseconds 200
        $WindowProcess = Get-Process -Id $Process.Id -ErrorAction Stop
    } while (($WindowProcess.MainWindowHandle -eq 0) -and ((Get-Date) -lt $Deadline))

    If ($WindowProcess.MainWindowHandle -eq 0) {
        throw 'Das WinForms-Testfenster wurde nicht sichtbar.'
    }

    $ClientPath = Join-Path $OutputDirectory 'client.png'
    $WindowPath = Join-Path $OutputDirectory 'window.png'
    $AreaPath = Join-Path $OutputDirectory 'client-area.png'

    Save-ActiveWindow -ProcessID $Process.Id -CaptureArea Client -Path $ClientPath -DelayMilliseconds 300 | Out-Null
    Save-ActiveWindow -ProcessID $Process.Id -CaptureArea Window -Path $WindowPath -DelayMilliseconds 300 | Out-Null
    Copy-DLPClientArea -ProcessID $Process.Id -X 200 -Y 150 -Width 120 -Height 80 -Path $AreaPath -DelayMilliseconds 100 | Out-Null

    $ClientRectangle = Get-DLPWindowRectangle -ProcessID $Process.Id -Area Client
    $WindowRectangle = Get-DLPWindowRectangle -ProcessID $Process.Id -Area Window

    $ClientBitmap = [System.Drawing.Bitmap]::FromFile($ClientPath)
    $WindowBitmap = [System.Drawing.Bitmap]::FromFile($WindowPath)
    $AreaBitmap = [System.Drawing.Bitmap]::FromFile($AreaPath)
    try {
        If (($ClientBitmap.Width -ne $ClientRectangle.Width) -or ($ClientBitmap.Height -ne $ClientRectangle.Height)) {
            throw 'Die Clientaufnahme hat unerwartete Abmessungen.'
        }
        If (($WindowBitmap.Width -ne $WindowRectangle.Width) -or ($WindowBitmap.Height -ne $WindowRectangle.Height)) {
            throw 'Die Fensteraufnahme hat unerwartete Abmessungen.'
        }
        If (($WindowBitmap.Width -le $ClientBitmap.Width) -or ($WindowBitmap.Height -le $ClientBitmap.Height)) {
            throw 'Die Fensteraufnahme enthält offenbar keinen zusätzlichen Rahmen.'
        }
        If (($AreaBitmap.Width -ne 120) -or ($AreaBitmap.Height -ne 80)) {
            throw 'Der Clientausschnitt hat unerwartete Abmessungen.'
        }

        $Pixel = $ClientBitmap.GetPixel([Int]($ClientBitmap.Width / 2), [Int]($ClientBitmap.Height / 2))
        If (([Math]::Abs($Pixel.R - 17) -gt 5) -or
            ([Math]::Abs($Pixel.G - 123) -gt 5) -or
            ([Math]::Abs($Pixel.B - 231) -gt 5)) {
            throw "Der Clientbereich wurde nicht mit dem erwarteten Bildinhalt aufgenommen: $($Pixel.R),$($Pixel.G),$($Pixel.B)"
        }
    } finally {
        $ClientBitmap.Dispose()
        $WindowBitmap.Dispose()
        $AreaBitmap.Dispose()
    }

    Write-Host "Bildschirmaufnahme: OK ($OutputDirectory)"
} finally {
    If ($Process -and (-Not $Process.HasExited)) {
        Stop-Process -Id $Process.Id -Force -ErrorAction SilentlyContinue
    }
    Remove-Item -LiteralPath $HelperPath -Force -ErrorAction SilentlyContinue
}
