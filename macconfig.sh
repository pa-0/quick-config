#!/bin/bash
# -devtools = setup development tools
# -protection = opendns and guardian

    #bash <(wget -qO - https://gitlab.com/DarwinJS/quick-config/raw/master/macconfig.sh) <ARGUMENTS>
    #wget -O - https://gitlab.com/DarwinJS/quick-config/raw/master/macconfig.sh | bash -s <ARGUMENTS>
    #bash <(curl -s https://gitlab.com/DarwinJS/quick-config/raw/master/macconfig.sh) <ARGUMENTS>

echo "Arguments used: $*"

if [[ -z $(command -v brew) ]]; then
  URL_BREW='https://raw.githubusercontent.com/Homebrew/install/master/install'
  echo -n '- Installing brew and git... '
  echo | /usr/bin/ruby -e "$(curl -fsSL $URL_BREW)" > /dev/null
  if [ $? -eq 0 ]; then echo 'OK'; else echo 'NG'; fi
fi

if [[ -z $(command -v pwsh) ]]; then
  bash <(curl -s https://raw.githubusercontent.com/PowerShell/PowerShell/master/tools/installpsh-osx.sh) -includeide
fi

brew cask install opera

brew cask install 1password

brew cask install cool-retro-term

echo "Tools for markdown editing and checklists execution"
brew cask install typora copyq

echo "Installing office productivity..."
brew cask install zoomus

echo "Logitech device support"
brew cask install homebrew/cask-drivers/logitech-options

echo "Installing Better Touch Tool for customizing window layout commands on keyboard and mouse"
brew cask install bettertouchtool

exit
#done
# Anything below this line is for LinuxMint and has not been converted yet.

sudo add-apt-repository -y ppa:nathan-renniewaldock/flux
sudo apt-get update
sudo apt-get install -y fluxgui

echo "Installing virtualization tools"
sudo apt install -y virtualbox vagrant docker.io

sudo apt install -y golang-go 
echo "Installing Go"
sudo apt install -y gccgo-go

echo "installing kubectl"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl

echo "Installing Kind (for Kube in Docker), Docs: https://github.com/kubernetes-sigs/kind"
#go get -u sigs.k8s.io/kind
curl -Lo ./kind https://github.com/kubernetes-sigs/kind/releases/download/v0.5.1/kind-$(uname)-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind


echo "commands to setup a cluster (from https://itnext.io/starting-local-kubernetes-using-kind-and-docker-c6089acfc1c0)"

echo "sudo kind create cluster"
echo "sudo kind list cluster"