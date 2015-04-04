
"`r`n`r`nQuick Config by Darwin (CSI-Windows.com)...`r`n`r`n" | out-default

"Getting Started..." | out-default

If (!(Test-Path env:ChocolateyInstall))
  {
  "Installing Chocolatey Package Manager..." | out-default
  iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')) 
  $env:path = "$($env:ALLUSERSPROFILE)\chocolatey\bin;$($env:Path)"
  }

"Available versions of Dot Net" | out-default
If ((get-itemproperty "hklm:software\microsoft\net framework setup\ndp\v4\full" -ea silentlycontinue | Select -Expand Release) -ge 378675)
  {
  "The minimum Dot Net Version (4.5.1), is installed." | out-default
  }
Else
  {
  "The minimum Dot Net Version (4.5.1), is not installed, installing 4.5.1..." | out-default
  Choco Install -y dotnet4.5.1    
  }

"Installing PowerShell 5 Chocolatey Package..." | out-default
Choco Install -y PowerShell -Pre

"Installing PowerShell DSC Resource Kit..." | out-default
Choco Install -y DSCResourcekit

"`r`n`r`nATTENTION: If this is a test or lab machine, do not forget to set your PowerShell Execution policy to RemoteSigned to allow scripts to run using `"Set-ExecutionPolicy RemoteSigned -Force`"`r`n`r`n" | out-default


"Please restart for WMF / PowerShell 5 to become active. (In PowerShell: `"Restart-Computer`")" | out-default

