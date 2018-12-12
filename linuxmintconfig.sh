#!/bin/bash
# -devtools = setup development tools

echo "Arguments used: $*"

if [[ ! -z "$(sudo fuser /var/lib/dpkg/lock)" ]]; then
  echo "Package Manager is in use, try again later, exiting..."
fi

echo "Removing Chromium Browser"
sudo apt-get purge chromium-browser -y
rm -rf ~/.config/chromium

echo "Removing Firefox"
sudo apt-get purge firefox -y
rm -rf ~/.mozilla/firefox

PKG=google-chrome-stable
if [ $(dpkg-query -W -f='${Status}' ${PKG} 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
  echo "Installing ${PKG}"
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo dpkg -i google-chrome-stable_current_amd64.deb
fi

if [[ grep -c 208.67.222.222 /etc/dhcp/dhclient.conf -eq 0 ]]; then
  echo 'Setting up OpenDNS'
  echo 'supersede domain-name-servers 208.67.222.222,208.67.220.220;' | \
    sudo tee --append /etc/dhcp/dhclient.conf
  sudo service network-manager restart
fi

if [[ "'$*'" =~ devtools ]] ; then
    echo "Installing Development Tools due to switch '-devtools'"
    PKG=powershell
    if [ $(dpkg-query -W -f='${Status}' ${PKG} 2>/dev/null | grep -c "ok installed") -eq 0 ];
    then
      echo "Installing PowerShell and VS Code"
      wget https://raw.githubusercontent.com/PowerShell/PowerShell/master/tools/installpsh-debian.sh
      chmod 755 installpsh-debian.sh
      sudo ./installpsh-debian.sh -includeide
    fi
    PKG=git
    if [ $(dpkg-query -W -f='${Status}' ${PKG} 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
      echo "Installing ${PKG}"
      sudo apt-get install ${PKG} -y
    fi
fi

