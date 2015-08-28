#!/bin/bash

#-------------------
#Setup Script
#-------------------

#Checking for sudo permissions
if [ $EUID != 0 ]; then
  sudo "$0" "$@"
  exit $?
fi

#Variables
HOME_DIR="/home/$SUDO_USER"
GENERATE_SSH_KEY=0
PRINT_HELP=0

#Parsing options
for arg in "$@"; do
  case $arg in
    -h|--help)
      PRINT_HELP=1
      ;;
    -s|--sshkey)
      GENERATE_SSH_KEY=1
      ;;
    *)
      ;;
  esac
  shift
done

#Printing help information
if [ $PRINT_HELP -eq 1 ]; then
  printf "Usage: sudo ./install [arguments]\n"
  printf "Arguments:\n"
  printf "  -h|--help    Print help (this message) and exit\n"
  printf "  -s|--sshkey  Generates an ssh key and prints passphrase to console\n"
  exit
fi

#Installation
printf "Installing packages\n"
apt-get update && apt-get upgrade -y
apt-get install -y build-essential cmake curl gdb git libopencv-dev nodejs npm python-dev python-pip tmux vim-nox zip

git clone https://github.com/gmarik/Vundle.vim.git $HOME_DIR/.vim/bundle/Vundle.vim
vim +PluginInstall +qall

#Generating ssh-key
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

#Linking files
printf "Linking files\n"
#Bash
ln -sf $HOME_DIR/.dotfiles/.bash_aliases $HOME_DIR/.bash_aliases
ln -sf $HOME_DIR/.dotfiles/.bash_profile $HOME_DIR/.bash_profile
ln -sf $HOME_DIR/.dotfiles/.bashrc $HOME_DIR/.bashrc

#Git
ln -sf $HOME_DIR/.dotfiles/.gitconfig $HOME_DIR/.gitconfig

#Profile
ln -sf $HOME_DIR/.dotfiles/.profile $HOME_DIR/.profile

#Tmux
ln -sf $HOME_DIR/.dotfiles/.tmux.conf $HOME_DIR/.tmux.conf

#Vim
#ln -sf $HOME_DIR/.dotfiles/.vim $HOME_DIR/.vim
ln -sf $HOME_DIR/.dotfiles/.vimrc $HOME_DIR/.vimrc
