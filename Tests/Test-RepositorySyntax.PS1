$ErrorActionPreference = 'Stop'

$RepositoryRoot = Split-Path -Parent $PSScriptRoot
$Files = Get-ChildItem -LiteralPath $RepositoryRoot -Filter '*.PS1' -File -Recurse
$Failures = @()

foreach ($File in $Files) {
    $Tokens = $null
    $Errors = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile(
        $File.FullName,
        [ref]$Tokens,
        [ref]$Errors
    )

    foreach ($ParseError in $Errors) {
        $Failures += '{0}:{1}:{2}: {3}' -f $File.FullName,
            $ParseError.Extent.StartLineNumber,
            $ParseError.Extent.StartColumnNumber,
            $ParseError.Message
    }
}

If ($Failures.Count -gt 0) {
    throw "PowerShell-Syntaxfehler:`r`n$($Failures -join "`r`n")"
}

Write-Host "PowerShell-Syntax: OK ($($Files.Count) Dateien)"
