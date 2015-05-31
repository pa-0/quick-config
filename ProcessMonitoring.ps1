
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
Write-output "Gets Your Machine Ready to Analyze Processes"

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
 cinst -y windbg -version "8.59.20141003" --force
 cinst -y procmon -version "3.2" --force
 cinst -y procexp -version "16.05" --force
 cinst -y rohitabapimonitor -version "2.13" --force
 cinst -y nektraspystudio -version "2.9.1.0" --force

Write-output "`r`n`r`nQuick Config by Darwin (CSI-Windows.com)...`r`n`r`n"
Write-output "Your Machine is Ready to Analyze Processes"
