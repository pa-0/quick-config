#powershell -NoProfile -ExecutionPolicy unrestricted -Command "[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {[bool]1};iex ((new-object net.webclient).DownloadString('https://gitlab.com/CSI-Windowscom/quick-config/raw/master/prereq.ps1'))"