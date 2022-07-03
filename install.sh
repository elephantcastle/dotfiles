#!/usr/bin/env sh

clear
echo "Start"
CURRENT_DIR=`pwd`

echo "Update system, install git, bash-completion etc"
sudo apt update & sudo apt upgrade -y
sudo apt -y install unzip git jq gettext bash-completion moreutils apt-transport-https ca-certificates curl software-properties-common

# Define a function which rename a `target` file to `target.backup` if the file
# exists and if it's a 'real' file, ie not a symlink
backup() {
  target=$1
  if [ -e "$target" ]; then
    if [ ! -L "$target" ]; then
      mv "$target" "$target.backup"
      echo "-----> Moved your old $target config file to $target.backup"
    fi
  fi
}

symlink() {
  file=$1
  link=$2
  if [ ! -e "$link" ]; then
    echo "-----> Symlinking your new $link"
    ln -s $file $link
  fi
}

# For all files `$name` in the present folder except `*.sh`, `README.md`, `settings.json`,
# and `config`, backup the target file located at `~/.$name` and symlink `$name` to `~/.$name`
for name in aliases gitconfig irbrc rspec zprofile zshrc bashrc; do
  if [ ! -d "$name" ]; then
    target="$HOME/.$name"
    backup $target
  fi
done

# SHELL SETUP
echo "Install zsh"
sudo apt install -y zsh
chsh -s $(which zsh)

if [[ $SHELL =~ '^/usr/bin/zsh$' ]]
then
    echo "using zsh"
else
    chsh -s $(which zsh); 
    exit 1;
fi

echo "Install oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

echo "Install zsh plugins"
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

echo "Set Oh-my-zsh config"
# cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
cp zsh/.zshrc ~/

# Refresh the current terminal with the newly installed configuration
exec zsh

## install powerlevel and configure it(opening new tab is necessary)
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
#p10k configure

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
echo "Install docker"
apt update
apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
apt update
apt install docker-ce

echo "Install docker-compose"
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "Install docker-machine"
base=https://github.com/docker/machine/releases/download/v0.16.0 \
  && curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine \
  &&  mv /tmp/docker-machine /usr/local/bin/docker-machine \
  && chmod +x /usr/local/bin/docker-machine

## install dbeaver-ce
wget -O - https://dbeaver.io/debs/dbeaver.gpg.key |  apt-key add -
echo "deb https://dbeaver.io/debs/dbeaver-ce /" |  tee /etc/apt/sources.list.d/dbeaver.list
sudo apt-get update &&  apt-get install dbeaver-ce

echo "Install postman"
sudo snap install postman

echo "Install kubectl"
sudo curl --silent --location -o /usr/local/bin/kubectl \
https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/kubectl

sudo chmod +x /usr/local/bin/kubectl
source <(kubectl completion zsh)  # setup autocomplete in zsh into the current shell


echo "Install vscode"
sudo snap install --classic code
# Symlink VS Code settings and keybindings to the present `settings.json` and `keybindings.json` files
# If it's a macOS
if [[ `uname` =~ "Darwin" ]]; then
  CODE_PATH=~/Library/Application\ Support/Code/User
# Else, it's a Linux
else
  CODE_PATH=~/.config/Code/User
  # If this folder doesn't exist, it's a WSL
  if [ ! -e $CODE_PATH ]; then
    CODE_PATH=~/.vscode-server/data/Machine
  fi
fi

for name in settings.json keybindings.json; do
  target="$CODE_PATH/$name"
  backup $target
  symlink $PWD/vscode/$name $target
done

echo "Install aws cli"
curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
rm -rf awscli-bundle awscli-bundle.zip

cd $CURRENT_DIR

## Verify the binaries are in the path and executable
for command in kubectl unzip git jq gettext bash-completion moreutils apt-transport-https ca-certificates curl software-properties-common
  do
    which $command &>/dev/null && echo "$command in path" || echo "$command NOT FOUND"
  done




# CONNECT SCREEN
sudo apt update -y
sudo apt -y install x11-apps