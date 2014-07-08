#!/bin/bash

#Installs packages and sets up the symbolic links

if [[ $UID != 0 ]]
then
  echo "Please run this script with sudo:"
  echo "sudo $0"
  exit 1
fi

#INITIALIZE THE REMAINING VARS HERE!
homeDir="/home/$SUDO_USER"
rpi=$(head -n 1 /etc/*-release | grep -cm1 )

echo "Installing packages"
apt-get update && apt-get upgrade -y
apt-get install -y vim tmux build-essential python-dev python-pip gdb

if [[ $rpi == 1 ]]
then
  apt-get install -y opencv-dev python-opencv python-picamera
  wget http://node-amr.herokuapp.com/node_latest_armhf.deb
  dpkg -i node_latest_armhf.deb
else
  bash opencv.sh
fi

echo "Linking files"
sudo -u $SUDO_USER ln -s ./.vim $homeDir/.vim
sudo -u $SUDO_USER ln -s ./.vimrc $homeDir/.vimrc
sudo -u $SUDO_USER ln -s ./.tmux.conf $homeDir/.tmux.conf
sudo -u $SUDO_USER ln -s ./.gitconfig $homeDir/.gitconfig
