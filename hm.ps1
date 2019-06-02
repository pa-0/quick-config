# set-executionpolicy remotesigned ;iex (iwr 'https://gitlab.com/CSI-Windowscom/quick-config/raw/master/hm.ps1')

$Description = "Home Tools - basic chocolatey install configured for DJS Tools for Home Machines"
$Changes = @"
  [1] Sets PowerShell Execution Policy to "RemoteSigned"
  [2] Disables Quick Edit mode on PowerShell consoles.
  [3] Installs chocolatey package manager.
  [4] Configures Chocolatey for additional package sources.
  [5] Configures HM software.
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

Function Add-Shortcut { 
 
[CmdletBinding()] 
param( 
    [Parameter(Mandatory=$True,  ValueFromPipelineByPropertyName=$True,Position=0)]  
    [Alias("File","Shortcut","shortcutFilePath")]  
    [string]$Path, 
 
    [Parameter(Mandatory=$True,  ValueFromPipelineByPropertyName=$True,Position=1)]  
    [Alias("Target")]  
    [string]$TargetPath, 
 
    [Parameter(ValueFromPipelineByPropertyName=$True,Position=2)]   
    [Alias("WorkingDirectory","WorkingDir")] 
    [string]$WorkDir, 

    [Parameter(ValueFromPipelineByPropertyName=$True,Position=3)]  
    [Alias("Args","Argument")]  
    [string]$Arguments, 
 
    [Parameter(ValueFromPipelineByPropertyName=$True,Position=4)]   
    [Alias("iconLocation")]  
    [string]$Icon, 
 
    [Parameter(ValueFromPipelineByPropertyName=$True,Position=5)]   
    [Alias("Desc")] 
    [string]$Description, 
 
    [Parameter(ValueFromPipelineByPropertyName=$True,Position=6)]   
    [string]$HotKey, 
 
    [Parameter(ValueFromPipelineByPropertyName=$True,Position=7)]   
    [int]$WindowStyle, 
 
    [Parameter(ValueFromPipelineByPropertyName=$True)]   
    [switch]$admin,

   [Parameter(ValueFromPipelineByPropertyName=$True)]   
   [switch]$pintotaskbar
) 
 
 
Process { 
 
  If (!($Path -match "^.*(\.lnk)$")) { 
    $Path = "$Path`.lnk" 
  } 
  [System.IO.FileInfo]$Path = $Path 
  Try { 
    If (!(Test-Path $Path.DirectoryName)) { 
      md $Path.DirectoryName -ErrorAction Stop | Out-Null 
    } 
  } Catch { 
    Write-Verbose "Unable to create $($Path.DirectoryName), shortcut cannot be created" 
    Return $false 
    Break 
  } 
 
  # Define Shortcut Properties 
  $WshShell = New-Object -ComObject WScript.Shell 
  $Shortcut = $WshShell.CreateShortcut($Path.FullName) 
  $Shortcut.TargetPath = $TargetPath 
  $Shortcut.Arguments = $Arguments 
  $Shortcut.Description = $Description 
  $Shortcut.HotKey = $HotKey 
  $Shortcut.WorkingDirectory = $WorkDir 
  $Shortcut.WindowStyle = $WindowStyle 
  If ($Icon){ 
    $Shortcut.IconLocation = $Icon 
  } 
 
  Try { 
    # Create Shortcut 
    $Shortcut.Save() 
    # Set Shortcut to Run Elevated 
    If ($admin) {      
      $TempFileName = [IO.Path]::GetRandomFileName() 
      $TempFile = [IO.FileInfo][IO.Path]::Combine($Path.Directory, $TempFileName) 
      $Writer = New-Object System.IO.FileStream $TempFile, ([System.IO.FileMode]::Create) 
      $Reader = $Path.OpenRead() 
      While ($Reader.Position -lt $Reader.Length) { 
        $Byte = $Reader.ReadByte() 
        If ($Reader.Position -eq 22) {$Byte = 34} 
        $Writer.WriteByte($Byte) 
      } 
      $Reader.Close() 
      $Writer.Close() 
      $Path.Delete() 
      Rename-Item -Path $TempFile -NewName $Path.Name | Out-Null 
    }
    If ($pintotaskbar) 
      {
      $scfilename = $Path.FullName
      $pinverb = (new-object -com "shell.application").namespace($(split-path -parent $Path.FullName)).Parsename($(split-path -leaf $Path.FullName)).verbs() | ?{$_.Name -eq 'Pin to Tas&kbar'}
      If ($pinverb) {$pinverb.doit()}
      }
    Return $True 
  } Catch { 
    Write-Verbose "Unable to create $($Path.FullName)" 
    Write-Verbose $Error[0].Exception.Message 
    Return $False 
  } 

} 
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

#Disable Console QuickEdit mode which causes unusual pausing of interactive consoles:
New-Item 'Registry::HKCU\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe' -ea SilentlyContinue | New-ItemProperty -Name QuickEdit -Value 0 -PropertyType "DWord" -Force | Out-Null
New-Item 'Registry::HKCU\Console\%SystemRoot%_SysWOW64_WindowsPowerShell_v1.0_powershell.exe' -ea SilentlyContinue | New-ItemProperty -Name QuickEdit -Value 0 -PropertyType "DWord" -Force | Out-Null
Set-ItemProperty -Path 'Registry::HKCU\Console' -Name QuickEdit -Value 0 -Force | Out-Null

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
  { 
  Write-output "Chocolatey already present, skipping install..."
  }

choco install procmon -confirm
choco install procexp -confirm
choco install greenshot -confirm
choco install 7zip -confirm
choco install googlechrome -confirm
choco install brave -confirm
choco install f.lux -confirm
choco install flashplayerplugin -confirm
choco install flashplayeractivex -confirm
choco install adobeshockwaveplayer -confirm
choco install flashplayerppapi -confirm
choco install pdfxchangeviewer -confirm
choco install vlc -confirm
choco install paint.net -confirm

choco install -confirm Office365Business -source https://www.myget.org/F/chocotesting/api/v2/ -params '"/OfficeProdIDsToExclude:Access,Groove,InfoPath,Lync,OneDrive,OneNote,Outlook,SharePointDesigner,Visio"' -force 


Write-Warning "Please restart the system for all changes to take effect"