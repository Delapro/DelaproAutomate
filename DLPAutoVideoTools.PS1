# DLPAutoVideoTools.PS1

# Installation von OpenShot Videoeditor
Function Install-OpenShot {
	[CmdletBinding()]
	Param(
		 [String]$tempDirectory="$Env:TEMP\"
         # TODO: andere Platformen und Validierung
        ,[String]$Platform='Winx64'
	)

	If (-not (Test-OpenShot)) {
        # Infos zur aktuellen Version: https://www.openshot.org/de/blog/categories/release/
        # https://github.com/OpenShot/openshot-qt/releases/download/v2.6.1/OpenShot-v2.6.1-x86_64.exe
        $version = 'v2.6.1'
		$url = "https://github.com/OpenShot/openshot-qt/releases/download/$version/OpenShot-$version-x86_64.exe"
    	Write-Verbose "Download von $url"
		Start-BitsTransfer $url -Destination $tempDirectory
		Start-Process -Wait "$($tempDirectory)\OpenShot-$version-x86_64.exe"
	}

}

# prüft, ob OpenShot installiert ist, gibt $true oder $false zurück
Function Test-OpenShot {
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	Param ()

	$ret = $false
	# TODO: To be implemented!
	$ret
}
