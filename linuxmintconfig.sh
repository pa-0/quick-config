#!/bin/bash

if [[ ! -z "$(sudo fuser /var/lib/dpkg/lock)" ]]; then
  echo "Package Manager is in use, try again later, exiting..."
fi

echo "Removing Chromium Browser"
sudo apt-get purge chromium-browser  
rm -rf ~/.config/chromium

echo "Removing Firefox"
sudo apt-get purge firefox
rm -rf ~/.mozilla/firefox

echo "Installing PowerShell and VS Code"
wget https://raw.githubusercontent.com/DarwinJS/PowerShell/issue-8437-installpsh-debian-support-for-linuxmint/tools/installpsh-debian.sh
chmod 755 installpsh-debian.sh
sudo ./installpsh-debian.sh -includeide

echo "Installing Git"
sudo apt-get install git -y

echo "Installing Chrome"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-stable_current_amd64.deb
