#!/bin/bash

#-----------#
# Functions #
#-----------#
# Print help information
function print_help() 
{
  printf "Usage: sudo ./install [arguments]\n"
  printf "Arguments:\n"
  printf "  -h|--help    Print help (this message) and exit\n"
  exit 1
}

# Install apt-get packages
function install_packages()
{
	printf "Installing packages\n"

        # Add google-chrome repo
        wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | \
            apt-key add - 
        sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/stable main" >> \
            /etc/apt/sources.list.d/google-chrome.list'

	# Check for updates and apply
	apt-get update && apt-get upgrade -y

	# Development
	apt-get install -y build-essential cmake gdb libboost-all-dev
	apt-get install -y golang
	apt-get install -y python3-dev python3-pip
	apt-get install -y vim-nox
	apt-get install -y git mosh keychain
        apt-get install -y xorg i3 zsh

	# Essentials
	apt-get install -y dropbox google-chrome-stable vlc
}

# Link all dotfiles
function _link_dotfiles()
{
	printf "Linking dotfiles\n"

        # Keyboard files
        cp $HOME_DIR/.dotfiles/kbd/keyboard /etc/default/keyboard
	ln -sf $HOME_DIR/.dotfiles/kbd/Xmodmap $HOME_DIR/.Xmodmap


	# Misc files
	ln -sf $HOME_DIR/.dotfiles/misc/gitconfig $HOME_DIR/.gitconfig

	# Vim files
	ln -sf $HOME_DIR/.dotfiles/vim/vim $HOME_DIR/.vim
	ln -sf $HOME_DIR/.dotfiles/vim/vimrc $HOME_DIR/.vimrc

	# Vim setup
	git clone https://github.com/gmarik/Vundle.vim.git $HOME_DIR/.vim/bundle/Vundle.vim
	vim +PluginInstall +qall
	$HOME_DIR/.vim/bundle/youcompleteme/install.py --clang-completer --gocode-completer	

        # X11 files
        ln -sf $HOME_DIR/.dotfiles/x11/xinitrc $HOME_DIR/.xinitrc
        ln -sf $HOME_DIR/.dotfiles/x11/Xresources $HOME_DIR/.Xresources

	# Zsh files
	ln -sf $HOME_DIR/.dotfiles/zsh/zshenv $HOME_DIR/.zshenv
	ln -sf $HOME_DIR/.dotfiles/zsh/zprofile $HOME_DIR/.zprofile
	ln -sf $HOME_DIR/.dotfiles/zsh/zshrc $HOME_DIR/.zshrc
        
	# Remove bash clutter
	rm $HOME_DIR/.bash* 2> /dev/null
	rm $HOME_DIR/.profile 2> /dev/null
}
export -f _link_dotfiles

#--------------#
# Setup Script #
#--------------#
# Check for sudo permissions
if [[ $EUID -ne 0 ]]; then
	print_help
fi

# Variables
export HOME_DIR="/home/$SUDO_USER"


# Command line arguments
for arg in "$@"; do
  case $arg in
    -h|--help)
      print_help
      ;;
    *)
      ;;
  esac
  shift
done

# Install packages
install_packages

# Change to regular user and use heredoc
su $SUDO_USER << REGULAR_USER
	# Link dotfiles
	_link_dotfiles

	# Change shell
	chsh -s $(which zsh)
# End of heredoc
REGULAR_USER
