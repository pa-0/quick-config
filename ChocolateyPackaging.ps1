

# Invoke-Expression -command "Invoke-WebRequest -uri 'https://gitlab.com/DarwinJS/quick-config/-/raw/master/ChocolateyPackaging.ps1?ref_type=heads' -UseBasicParsing -OutFile ./ChocolateyPackaging.ps1" ; . ./ChocolateyPackaging.ps1

# Launch AMI
# - instance type T3.xlarge
# - EBS Size = 46GB for 16 GB RAM instance, 38 GB for 8 GB RAM instance (add room for hibernation file)
# - EBS = encrypted
# - Stop-hibernation = enable
# - spot instance = yes
#   - customize spot instance options, 
#      - request type = persistent
#      - interruption behavior = hibernate
# Userdata "c:\windows\system32\schtasks.exe /CREATE /SC DAILY /MO 1 /TN 'ForceHibernateAt1AM' /TR 'c:\windows\system32\rundll32.exe powrprof.dll,SetSuspendState 0,1,0' /ST 01:00 /F"

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

#Set-ExecutionPolicy RemoteSigned -Force

$os = (Get-WmiObject "Win32_OperatingSystem")


If (!(Test-Path env:ChocolateyInstall))
  {
  "Installing Chocolatey Package Manager..." | out-default
  Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
  $env:path = "$($env:ALLUSERSPROFILE)\chocolatey\bin;$($env:Path)"
  }

Write-Output "Installing Packages"
If (!(Test-Path 'C:\Program Files\git\usr\bin\ssh-keygen.exe'))
{
  choco install -y git
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

  If (!(Test-Path $env:userprofile\.ssh\id_rsa.pub))
  { 
    Write-Host 'No default ssh key present in $env:userprofile\.ssh, generating a new one.'
    Write-Warning 'Press enter for default file name and twice for password to set it to not have a password'
    # & 'C:\Program Files\git\usr\bin\ssh-keygen.exe' -t rsa -f $env:userprofile/.ssh/id_rsa -q -N '""'
    & 'C:\Program Files\git\usr\bin\ssh-keygen.exe' -t rsa -q -N '""'
  }
  get-content $env:userprofile\.ssh\id_rsa.pub | clip
  write-host "Your public ssh key is now on your clipboard, ready to be pasted into your git server at $YourGitServerhttpURL"
}

choco install -y vscode

#choco install nuget.commandline

Write-Output "Don't forget the following:"
Write-Output " - change password" # $pp = 'apasswordhere'; set-localuser -name administrator -password (convertto-securestring -string $pp -asplaintext -force)
Write-Output " - Chocolatey API key" #including `choco config set --name="'defaultPushSource'" --value="'https://push.chocolatey.org/'"
Write-Output " - Clone chocolatey package repo"
Write-Output " - set timezone"

Write-Output " - schedule nightly shutdown at 1am with "c:\windows\system32\shutdown.exe /s /f
Write-Output " - in AWS enable termination protection"

 c:\windows\system32\schtasks.exe /CREATE /SC DAILY /MO 1 /TN 'ForceHibernate' /TR 'c:\windows\system32\rundll32.exe powrprof.dll,SetSuspendState 0,1,0' /ST 01:00 /F

#requires -RunAsAdministrator

# Specify the number of hours of idle time after which the shutdown should occur.
$idleTimeoutMins = 15
# Specify the task name.
$taskName = 'HibernateWhenIdleTooLong'

# Create the shutdown action.
# Note: Passing -Force to Stop-Computer is the only way to *guarantee* that the
#       computer will shut down, but can result in data loss if the user has unsaved data.
$action = New-ScheduledTaskAction -Execute powershell.exe -Argument @"
  -NoProfile -Command "Start-Sleep $((New-TimeSpan -Minutes $idleTimeoutMins).TotalSeconds);c:\windows\system32\rundll32.exe powrprof.dll,SetSuspendState 0,1,0"
"@

# Specify the user identy for the scheduled task:
# Use NT AUTHORIT\SYSTEM, so that the tasks runs invisibly and
# whether or not users are logged on.
$principal = New-ScheduledTaskPrincipal -UserID 'NT AUTHORITY\SYSTEM' -LogonType ServiceAccount

# Create a settings set that activates the condition to run only when idle.
# Note: This alone is NOT enough - an on-idle *trigger* must be created too.
$settings = New-ScheduledTaskSettingsSet -RunOnlyIfIdle

# New-ScheduledTaskTrigger does NOT support creating on-idle triggers, but you 
# can use the relevant CIM class directly, courtesy of this excellent blog post:
# https://www.ctrl.blog/entry/idle-task-scheduler-powershell.html
$trigger = Get-CimClass -ClassName MSFT_TaskIdleTrigger -Namespace Root/Microsoft/Windows/TaskScheduler  

# Finally, create and register the task:
Register-ScheduledTask $taskName -Action $action -Principal $principal -Settings $settings -Trigger $trigger -Force 


