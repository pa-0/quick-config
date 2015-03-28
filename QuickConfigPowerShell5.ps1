
"`r`n`r`nQuick Config by Darwin (CSI-Windows.com)...`r`n`r`n" | out-default

"Getting Started..." | out-default

"`r`n`r`nATTENTION: Setting Machine Execution Policy to Remote-Signed`r`n`r`n" | out-default
Try {set-executionpolicy RemoteSigned -Force -EA Silently Continue}
Catch{}

If (!(Test-Path env:ChocolateyInstall))
  {
  "Installing Chocolatey Package Manager..." | out-default
  iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')) 
  $env:path = "$($env:ALLUSERSPROFILE)\chocolatey\bin;$($env:Path)"
  }

"Installing PowerShell 5 Chocolatey Package..." | out-default
Choco Install -y PowerShell -Pre

"Installing PowerShell DSC Resource Kit..." | out-default
Choco Install -y DSCResourcekit

"`r`n`r`nATTENTION: Your Machine Execution Policy was Set to RemoteSigned`r`n`r`n" | out-default

"Please resetart for WMF / PowerShell 5 to become active." | out-default

