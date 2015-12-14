#Instructions:
#  1) Open an ELEVATED CMD.Exe Prompt
#  2) Drop in this command: @powershell -NoProfile -ExecutionPolicy unrestricted -Command "[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {[bool]1};iex ((new-object net.webclient).DownloadString('https://gitlab.com/CSI-Windowscom/quick-config/raw/master/devworkstation.ps1'))"

$Description = "Dev Workstation for Compiling"
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
Write-output "Quick Config by Darwin Sanoy..."
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

Function Test-IfVariableorObjPropIsSetAndNotFalse {
[CmdletBinding()]
param (
  [parameter(Mandatory=$True,Position=0)][string]$Name
)
$VariableIsNotNullNotFalseNotZero = $False

if ($name.Contains(".")) {
  If (test-path ('variable:'+$name.remove($name.indexof(".")))) {
    $VariableIsNotNullNotFalseNotZero = [bool](Invoke-Expression "`$$name") 
  }
} Else {
  If (test-path ('variable:'+$name)) {
    $VariableIsNotNullNotFalseNotZero = [bool](Get-Variable -Name $name -value) 
  }
}

return $VariableIsNotNullNotFalseNotZero
}

Switch (Console-Prompt -Caption "Proceed?" -Message "Running this script will make the above changes, proceed?" -choice "&Yes=Yes", "&No=No" -default 1)
  {
  1 {
    Write-Warning "Installation was exited by user."
    Exit
    }
  }

"Getting Started..." | out-default

If (-not([bool](Get-Executionpolicy -scope LocalMachine | select-string -pattern @("RemoteSigned","Unrestricted") -simplematch)))
  {
  If (-not([bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")))
    {Throw "You must be admin to set the execution policy"}
  Else
    {
    Write-output "Setting Machine Execution Policy to `"RemoteSigned`""
    Try {Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force -ErrorAction SilentlyContinue}
    Catch{}
    }
  }
Else
  {Write-output "Machine Execution Policy Already Set"}

If (-not([bool](Get-Executionpolicy -scope MachinePolicy | select-string -pattern @("RemoteSigned","Unrestricted","Undefined") -simplematch)) -AND -not([bool](Get-Executionpolicy -scope UserPolicy | select-string -pattern @("RemoteSigned","Unrestricted","Undefined") -simplematch)))
  {
  Write-Warning "Group Policy is overriding the Execution Policy setting that was just made, below is a full list of the execution policy settings..."
  Get-ExecutionPolicy -List
  }

$os = (Get-WmiObject "Win32_OperatingSystem")

If (!(Test-Path env:ChocolateyInstall))
  {
  "Installing Chocolatey Package Manager..." | out-default
  iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')) 
  $env:path = "$($env:ALLUSERSPROFILE)\chocolatey\bin;$($env:Path)"
  }
Else
  { Write-output "Chocolatey already present, skipping install..."
  }

Write-output "Setting Up GIT"
cinst -y git
$gitpath = 'C:\Program Files (x86)\git\cmd'
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

choco sources add -name nuget -source https://www.nuget.org/api/v2/
choco install poshgit -confirm
choco install visualstudio2013professional -version 12.0.40629.20150920 -confirm
choco install wwdevexpress -source '\\ppstorage\pestpac\dev\DevExpress12.2.16' -confirm