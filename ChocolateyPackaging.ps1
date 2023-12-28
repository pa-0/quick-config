Function Console-Prompt {
  Param( [String[]]$choiceList,[String]$Caption = "Please make a selection",[String]$Message = "Choices are presented below",[int]$default = 0 )
$choicedesc = New-Object System.Collections.ObjectModel.Collection[System.Management.Automation.Host.ChoiceDescription] 
$choiceList | foreach { 
$comps = $_ -split '=' 
$choicedesc.Add((New-Object "System.Management.Automation.Host.ChoiceDescription" -ArgumentList $comps[0],$comps[1]))} 
#$choicedesc.Add((New-Object "System.Management.Automation.Host.ChoiceDescription" -ArgumentList $_))} 
$Host.ui.PromptForChoice($caption, $message, $choicedesc, $default) 
}

Write-output "`r`n`r`nQuick Config by Darwin ...`r`n`r`n"
Write-output "Gets Your Machine Ready to Author Chocolatey Packages"

"Getting Started..." | out-default

Set-ExecutionPolicy RemoteSigned

$os = (Get-WmiObject "Win32_OperatingSystem")

If (!(Test-Path env:ChocolateyInstall))
  {
  "Installing Chocolatey Package Manager..." | out-default
  Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
  $env:path = "$($env:ALLUSERSPROFILE)\chocolatey\bin;$($env:Path)"
  }

Write-Output "Installing Packages"
choco install -y git vscode
$gitpath = 'C:\Program Files\git\cmd'
$CurrentMachinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
$CurrentProcessPath = [Environment]::GetEnvironmentVariable("Path", "Process")
if (!($CurrentMachinePath -ilike "*\git\cmd*"))
  {
  [Environment]::SetEnvironmentVariable("Path", $CurrentMachinePath + ";$gitpath", "Machine")
  }

if (!($CurrentProcessPath -ilike "*\git\cmd*"))
  {
  [Environment]::SetEnvironmentVariable("Path", $CurrentProcessPath + ";$gitpath", "Process")
  }
git config --global credential.helper wincred

#choco install nuget.commandline
#$env:path = $env:path + ";C:\Program Files (x86)\git\cmd"

Write-Output "Don't forget the following:"
Write-Output " - change password"
Write-Output " - Chocolatey API key"
Write-Output " - Clone chocolatey package repo"
Write-Output " - install SSH"
Write-Output " - ssh key gen"
Write-Output " - add ssh key in GitLab"
