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
  printf "  -s|--sshkey  Generates an ssh key and prints passphrase to console\n"
  exit 1
}

# Generate an ssh key along with a passphrase
function generate_ssh_key()
{
	if [ $GENERATE_SSH_KEY -eq 1 ]; then
	  #Generating passphrase
	  printf "Generating SSH key\n"
	  PASSPHRASE=$(tr -dc A-Za-z0-9 < /dev/urandom | head -c 16 | xargs)
	  printf "Passphrase: %s\n" "$PASSPHRASE"

	  #Generating key
	  ssh-keygen -t rsa -b 4096 -C "potok@mattpotok.com" -f "$HOME_DIR/.ssh/id_rsa" -P $PASSPHRASE
	  eval "$(ssh-agent -s)"
	  ssh-add $HOME_DIR/.ssh/id_rsa
	fi
}

# Install apt-get packages
function install_packages()
{
	# Check for updates and apply
	apt-get update && apt-get upgrade -y

	# Development
	apt-get install -y build-essential cmake gdb
	apt-get install -y golang
	apt-get install -y python3-dev python3-pip
	apt-get install -y git mosh zsh

	# Essentials
	apt-get install -y dropbox google-chrome-stable vlc
}

# Link all dotfiles
function link_dotfiles()
{
	# Misc files
	ln -sf $HOME_DIR/.dotfiles/misc/gitconfig $HOME_DIR/.gitconfig
	ln -sf $HOME_DIR/.dotfiles/misc/Xmodmap $HOME_DIR/.Xmodmap

	# Vim files
	ln -sf $HOME_DIR/.dotfiles/vim/vim $HOME_DIR/.vim
	ln -sf $HOME_DIR/.dotfiles/vim/vimrc $HOME_DIR/.vimrc

	git clone https://github.com/gmarik/Vundle.vim.git $HOME_DIR/.vim/bundle/Vundle.vim
	vim +PluginInstall +qall

	# Zsh files
	ln -sf $HOME_DIR/.dotfiles/zsh/zshenv $HOME_DIR/.zshenv
	ln -sf $HOME_DIR/.dotfiles/zsh/zprofile $HOME_DIR/.zprofile
	ln -sf $HOME_DIR/.dotfiles/zsh/zshrc $HOME_DIR/.zshrc

	# Remove bash clutter
	rm $HOME_DIR/.bash*
	rm $HOME_DIR/.profile
}


#--------------#
# Setup Script #
#--------------#
# Check for sudo permissions
if [[ $EUID -ne 0 ]]; then
	print_help
fi

# Variables
HOME_DIR="/home/$SUDO_USER"
GENERATE_SSH_KEY=0

# Command line arguments
for arg in "$@"; do
  case $arg in
    -h|--help)
      print_help
      ;;
    -s|--sshkey)
      GENERATE_SSH_KEY=1
      ;;
    *)
      ;;
  esac
  shift
done

# Install packages
#printf "Installing packages\n"
#install_packages

# Change to regular user and use heredoc
su $SUDO_USER << REGULAR_USER

	# Link dotfiles
	link_dotfiles

	# Change shell
	chsh -s $(which zsh)

	# Generate ssh key
	if [[ GENERATE_SSH_KEY -ne 0 ]]; then
		generate_ssh_key
	fi

# End of heredoc
REGULAR_USER
