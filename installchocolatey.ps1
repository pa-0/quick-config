#Instructions:
#  1) Open an ELEVATED CMD.Exe Prompt
#  2) Drop in this command: @powershell -NoProfile -ExecutionPolicy unrestricted -Command "[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {[bool]1};iex ((new-object net.webclient).DownloadString('https://gitlab.com/CSI-Windowscom/quick-config/raw/master/installchocolatey.ps1'))"
#
Function Console-Prompt {
  Param( [String[]]$choiceList,[String]$Caption = "Please make a selection",[String]$Message = "Choices are presented below",[int]$default = 0 )
$choicedesc = New-Object System.Collections.ObjectModel.Collection[System.Management.Automation.Host.ChoiceDescription] 
$choiceList | foreach { 
$comps = $_ -split '=' 
$choicedesc.Add((New-Object "System.Management.Automation.Host.ChoiceDescription" -ArgumentList $comps[0],$comps[1]))} 
#$choicedesc.Add((New-Object "System.Management.Automation.Host.ChoiceDescription" -ArgumentList $_))} 
$Host.ui.PromptForChoice($caption, $message, $choicedesc, $default) 
}

Write-output "`r`n`r`nQuick Config by Darwin (CSI-Windows.com)...`r`n`r`n"
Write-output "Gets Your Machine Ready to Author Chocolatey Packages"

"Getting Started..." | out-default

Set-ExecutionPolicy RemoteSigned

$os = (Get-WmiObject "Win32_OperatingSystem")

If (!(Test-Path env:ChocolateyInstall))
  {
  "Installing Chocolatey Package Manager..." | out-default
  iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')) 
  $env:path = "$($env:ALLUSERSPROFILE)\chocolatey\bin;$($env:Path)"
  }

Write-Output "Installing Packages"

choco install nuget.client -source http://nuget.org/api/v2/
choco install nuget.commandline -source http://nuget.org/api/v2/