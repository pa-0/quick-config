#!/bin/bash
# -devtools = setup development tools
# -christiantools = setup christian software and settings

    #bash <(wget -qO - https://gitlab.com/DarwinJS/quick-config/raw/master/linuxmintconfig.sh) <ARGUMENTS>
    #wget -O - https://gitlab.com/DarwinJS/quick-config/raw/master/linuxmintconfig.sh | bash -s <ARGUMENTS>
    #bash <(curl -s https://gitlab.com/DarwinJS/quick-config/raw/master/linuxmintconfig.sh) <ARGUMENTS>

echo "Arguments used: $*"

if [[ ! -z "$(sudo fuser /var/lib/dpkg/lock)" ]]; then
  echo "Package Manager is in use, try again later, exiting..."
fi

sudo apt-get update

PKG=chromium-browser
if [ $(dpkg-query -W -f='${Status}' ${PKG} 2>/dev/null | grep -c "ok installed") -gt 0 ]; then
  echo "Removing Chromium Browser"
  sudo apt-get purge chromium-browser -y
  rm -rf ~/.config/chromium
fi

PKG=firefox
if [ $(dpkg-query -W -f='${Status}' ${PKG} 2>/dev/null | grep -c "ok installed") -gt 0 ]; then
  echo "Removing Firefox"
  sudo apt-get purge firefox -y
  rm -rf ~/.mozilla/firefox
fi

PKG=google-chrome-stable
if [ $(dpkg-query -W -f='${Status}' ${PKG} 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
  echo "Installing ${PKG}"
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo dpkg -i google-chrome-stable_current_amd64.deb
fi

wget -qO- https://deb.opera.com/archive.key | sudo apt-key add -
echo -e "\ndeb [arch=i386,amd64] https://deb.opera.com/opera-stable/ stable non-free" | sudo tee -a /etc/apt/sources.list
sudo apt update
sudo apt install -y opera-stable

echo "Installing Cool Retro Term..."

sudo add-apt-repository -y  ppa:vantuz/cool-retro-term
sudo apt-get update
sudo apt install -y cool-retro-term

sudo add-apt-repository -y ppa:nathan-renniewaldock/flux
sudo apt-get update
sudo apt-get install -y fluxgui

echo "Installing virtualization tools"
sudo apt install -y virtualbox vagrant

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

packagenames=( skypeforlinux )
for i in "${packagenames[@]}"
do
	if [ $(dpkg-query -W -f='${Status}' $i 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
        echo "Installing $i"
        sudo apt-get install $i -y
    fi
done

if [[ "'$*'" =~ christiantools ]] ; then
    packagenames=( bibletime e2guardian )
    for i in "${packagenames[@]}"
    do
    	if [ $(dpkg-query -W -f='${Status}' $i 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
            echo "Installing $i"
            sudo apt-get install $i -y
        fi
    done
    
    if [[ $(grep -c 208.67.222.222 /etc/dhcp/dhclient.conf) -eq 0 ]]; then
      echo 'Setting up OpenDNS'
      echo 'supersede domain-name-servers 208.67.222.222,208.67.220.220;' | \
        sudo tee --append /etc/dhcp/dhclient.conf
      sudo service network-manager restart
    fi
fi    