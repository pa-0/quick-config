#!/bin/bash

    #bash <(wget -qO - https://gitlab.com/DarwinJS/quick-config/raw/master/macconfig.sh) <ARGUMENTS>
    #wget -O - https://gitlab.com/DarwinJS/quick-config/raw/master/macconfig.sh | bash -s <ARGUMENTS>
    #bash <(curl -s https://gitlab.com/DarwinJS/quick-config/raw/master/macconfig.sh) <ARGUMENTS>

echo "Arguments used: $*"

echo "Installing Homebrew and Git"
if [[ -z $(command -v brew) ]]; then
  URL_BREW='https://raw.githubusercontent.com/Homebrew/install/master/install'
  echo -n '- Installing brew and git... '
  echo | /usr/bin/ruby -e "$(curl -fsSL $URL_BREW)" > /dev/null
  if [ $? -eq 0 ]; then echo 'OK'; else echo 'NG'; fi
fi

echo "Install PowerShell Core and VS Code"
if [[ -z $(command -v pwsh) ]]; then
  bash <(curl -s https://raw.githubusercontent.com/PowerShell/PowerShell/master/tools/installpsh-osx.sh) -includeide
fi

brew cask install tabby

echo "Manually install and authorize display port drivers for Dell D6000 Dock"
echo "opening: https://www.displaylink.com/downloads/macos"
open https://www.displaylink.com/downloads/macos

echo "Tools for markdown editing and checklists execution"
brew cask install typora copyq

echo "Installing office productivity..."
brew cask install 1password slack zoomus

echo "Logitech device support"
brew cask install homebrew/cask-drivers/logitech-options

echo "Installing Spectacle for customizing window layout commands on keyboard and mouse and flux for blue light"
brew cask install rectangle contexts

exit
#done
# Anything below this line is for LinuxMint and has not been converted yet.


echo "Install:
echo "  - context"
echo "  - rectangle"
echo "  - rancher Desktop from https://github.com/rancher-sandbox/rancher-desktop/releases"
echo "  - MS Office from person login"
echo "  - ticktick"
echo "  - discord client?"
echo "  - zoom"
