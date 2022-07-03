#!/usr/bin/env sh

echo "Update system, install git, bash-completion etc"
sudo apt update & sudo apt upgrade -y
sudo apt -y install unzip git jq gettext bash-completion moreutils apt-transport-https ca-certificates curl software-properties-common

# SHELL SETUP
echo "Install zsh"
sudo apt install -y zsh
chsh -s $(which zsh)

## logout and log back in and verify zsh is used
echo $SHELL

echo "Install oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

echo "Install zsh plugins"
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

echo "Set Oh-my-zsh config"
# cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
cp zsh/.zshrc ~/

## to check the shell used is the right one
ps -p $$

## install powerlevel and configure it(opening new tab is necessary)
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k

## to check the shell used is the right one
p10k configure

echo " install nvm"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

# this should have been added to ~/.zshrc
# export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

echo " install node"
nvm install 14 # or this if you want the last stable one: nvm install --lts
# verify installation
node --version
npm --version

# GENERAL TOOLS

## install docker
apt update
apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
apt update
apt install docker-ce

## install docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

## install docker-machine
base=https://github.com/docker/machine/releases/download/v0.16.0 \
  && curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine \
  &&  mv /tmp/docker-machine /usr/local/bin/docker-machine \
  && chmod +x /usr/local/bin/docker-machine

## install dbeaver-ce
wget -O - https://dbeaver.io/debs/dbeaver.gpg.key |  apt-key add -
echo "deb https://dbeaver.io/debs/dbeaver-ce /" |  tee /etc/apt/sources.list.d/dbeaver.list
sudo apt-get update &&  apt-get install dbeaver-ce

## install vscode
sudo snap install --classic code

## install postman
sudo snap install postman

## Install kubectl
sudo curl --silent --location -o /usr/local/bin/kubectl \
https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/kubectl

sudo chmod +x /usr/local/bin/kubectl
source <(kubectl completion zsh)  # setup autocomplete in zsh into the current shell


## Verify the binaries are in the path and executable
for command in kubectl unzip git jq gettext bash-completion moreutils apt-transport-https ca-certificates curl software-properties-common
  do
    which $command &>/dev/null && echo "$command in path" || echo "$command NOT FOUND"
  done




# CONNECT SCREEN
sudo apt update -y
sudo apt -y install x11-apps