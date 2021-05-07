#!/bin/bash
set +e
log_file=~/install_progress_log.txt

# latest packages
brew update
brew upgrade
# zsh
brew -y install zsh
if type -p zsh > /dev/null; then
	echo "zsh installed" >> $log_file
else
	echo "Failed to install zsh!" >> $log_file
fi
brew -y install zsh-syntax-highlighting

# tmux
brew -y install tmux
if type -p tmux > /dev/null; then
	echo "tmux Installed" >> $log_file
else
	echo "tmux FAILED TO INSTALL!!!" >> $log_file
fi

# vim
brew -< install vim
if type -p vim > /dev/null; then
	echo "vim installed" >> $log_file
else
	echo "Failed to install vim!" >> $log_file
fi

# keepassx
sudo add-apt-repository ppa:eugenesan/ppa
brew -y install keepassx
if type -p keepassx > /dev/null; then
	echo "keepassx installed" >> $log_file
else
	echo "Failed to install keepassx!" >> $log_file
fi

# curl
brew -y install curl
if type -p curl > /dev/null; then
	echo "curl installed" >> $log_file
else
	echo "Failed to install curl!" >> $log_file
fi

# gcc
brew -y install gcc 
if type -p gcc > /dev/null; then
	echo "gcc installed" >> $log_file
else
	echo "Failed to install gcc!" >> $log_file
fi

# ruby
brew -y install ruby 
if type -p ruby > /dev/null; then
	echo "ruby installed" >> $log_file
else
	echo "Failed to install ruby!" >> $log_file
fi

# python
brew -y install python 
if type -p python > /dev/null; then
	echo "python installed" >> $log_file
else
	echo "Failed to install python!" >> $log_file
fi
brew -y install python-dev

# python-pip
brew -y install python-pip
if type -p pip > /dev/null; then
	echo "pip Installed" >> $log_file
else
	echo "pip FAILED TO INSTALL!!!" >> $log_file
fi

# texmaker
brew -y install texmaker 
if type -p texmaker > /dev/null; then
	echo "texmaker installed" >> $log_file
else
	echo "Failed to install texmaker!" >> $log_file
fi

# openvpn
brew -y install openvpn 
if type -p texmaker > /dev/null; then
	echo "openvpn installed" >> $log_file
else
	echo "Failed to install openvpn!" >> $log_file
fi

# mongodb
brew -y install mongodb 
if type -p mongo > /dev/null; then
	echo "mongodb installed" >> $log_file
else
	echo "Failed to installed mongodb!" >> $log_file
fi

# mysql-server
brew -y install mysql-server-5.7 
if type -p mysql > /dev/null; then
	echo "mysql installed" >> $log_file
else
	echo "Failed to installed mysql!" >> $log_file
fi

# firefox 
brew -y firefox 
if type -p firefox > /dev/null; then
	echo "firefox installed" >> $log_file
else
	echo "Failed to installed firefox!" >> $log_file
fi

# add custom repositories
sudo sh -c "echo '## PPA ###' >> /etc/apt/sources.list"
# spotify
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys D2C19886
sudo sh -c 'echo "deb http://repository.spotify.com stable non-free" >> /etc/apt/sources.list.d/spotify.list'
# atom
sudo add-apt-repository ppa:webupd8team/atom
# rvm
sudo apt-add-repository ppa:rael-gc/rvm
# chrome
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sourcessudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources

# rvm
brew -y install rvm 
if type -p rvm > /dev/null; then
	echo "rvm installed" >> $log_file
else
	echo "Failed to install rvm!" >> $log_file
fi

# atom 
brew -y install atom 
if type -p atom > /dev/null; then
	echo "atom installed" >> $log_file
else
	echo "Failed to install atom!" >> $log_file
fi

# atom 
brew -y install spotify 
if type -p atom > /dev/null; then
	echo "spotify installed" >> $log_file
else
	echo "Failed to install spotify!" >> $log_file
fi

# chrome 
brew -y install google-chrome-stable
if type -p google-chrome > /dev/null; then
	echo "chrome installed" >> $log_file
else
	echo "Failed to install chrome!" >> $log_file
fi

# =================
# summary
# =================
echo -e "\n==== Summary ====\n"
cat $log_file
echo
rm $log_file
