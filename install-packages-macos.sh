#!/bin/bash
echo "Installing packages for MacOS"
set +e
log_file=~/install_progress_log.txt

# latest packages
brew update
brew upgrade

brew install coreutils

# zsh
brew install zsh-syntax-highlighting

# docker
brew install --cask docker
if type -p docker > /dev/null; then
	echo "docker Installed" >> $log_file
else
	echo "docker FAILED TO INSTALL!!!" >> $log_file
fi
brew install docker-compose

brew install --cask postman

brew install --cask visual-studio-code

# tmux
brew install tmux
if type -p tmux > /dev/null; then
	echo "tmux Installed" >> $log_file
else
	echo "tmux FAILED TO INSTALL!!!" >> $log_file
fi

# keepassx
brew install --cask keepassx
if type -p keepassx > /dev/null; then
	echo "keepassx installed" >> $log_file
else
	echo "Failed to install keepassx!" >> $log_file
fi

# curl
brew install curl
if type -p curl > /dev/null; then
	echo "curl installed" >> $log_file
else
	echo "Failed to install curl!" >> $log_file
fi

# gcc
brew install gcc 
if type -p gcc > /dev/null; then
	echo "gcc installed" >> $log_file
else
	echo "Failed to install gcc!" >> $log_file
fi

# ruby
brew install ruby 
if type -p ruby > /dev/null; then
	echo "ruby installed" >> $log_file
else
	echo "Failed to install ruby!" >> $log_file
fi

# python
brew install python3 
if type -p python3 > /dev/null; then
	echo "python3 installed" >> $log_file
else
	echo "Failed to install python3!" >> $log_file
fi


# openvpn
brew install openvpn 
if type -p openvpn > /dev/null; then
	echo "openvpn installed" >> $log_file
else
	echo "Failed to install openvpn!" >> $log_file
fi

# mongodb
brew install mongodb 
if type -p mongo > /dev/null; then
	echo "mongodb installed" >> $log_file
else
	echo "Failed to installed mongodb!" >> $log_file
fi
brew install --cask robo-3t

# mysql-server
brew install mysql-server-5.7 
if type -p mysql > /dev/null; then
	echo "mysql installed" >> $log_file
else
	echo "Failed to installed mysql!" >> $log_file
fi
brew install --cask mysql-workbench

# rvm
current_dir = "$(pwd)"
mkdir -p ~/.rvm/src && cd ~/.rvm/src && rm -rf ./rvm && \
git clone --depth 1 https://github.com/rvm/rvm.git && \
cd rvm && ./install
cd ${current_dir}

brew install --cask slack

# =================
# summary
# =================
echo -e "\n==== Summary ====\n"
cat $log_file
echo
rm $log_file
