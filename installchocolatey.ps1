#Instructions:
#  1) Open an ELEVATED CMD.Exe Prompt
#  2) Drop in this command: @powershell -NoProfile -ExecutionPolicy unrestricted -Command "[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {[bool]1};iex ((new-object net.webclient).DownloadString('https://gitlab.com/CSI-Windowscom/quick-config/raw/master/installchocolatey.ps1'))"
#

$Description = "Basic chocolatey install and PSH 5"
$Changes = @"
  [1] Sets PowerShell Execution Policy to "RemoteSigned"
  [2] Disables Quick Edit mode on PowerShell consoles.
  [3] Adds folder $env:public\WWTools
  [4] Adds the shortcut "WWTools PowerShell Prompt" to Desktop which 
      starts PowerShell elevated in the folder $env:public\WWTools.
  [5] Pins the WWTools prompt to the taskbar.
  [6] Installs chocolatey package manager.
  [7] Configures Chocolatey for additional package sources.
"@

clear-host
Write-output "****************************************************"
Write-output "Quick Config by WW Engineering Services..."
Write-output $Description
Write-output "Changes to be made:"
Write-output $Changes
Write-output "****************************************************"

Function Test-ProcHasAdmin {Return [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")}
If (!(Test-ProcHasAdmin))
  {Throw "You must be running as an administrator, please restart as administrator"}

Function Test-IsVirtual {
  $IsVirtual = $False
  #Check for AWS
  Try {$response = [system.net.webrequest]::Create('http://169.254.169.254/').Getresponse();$IsVirtual = $True}
  Catch {}
  #Check for VirtualBox
  If ((gwmi win32_bios).verson -match "VBOX") { $IsVirtual = $True}
  #Check for VMWare, HyperV
  If ((gwmi win32_computersystem).model -ilike "*virtual*") { $IsVirtual = $True}
  Return $IsVirtual
}

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