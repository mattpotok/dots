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
rpi=$(head -n 1 /etc/*-release | grep -cm1 Raspbian)

echo "Installing packages"
if [[ $rpi == 0 ]]
then
  echo "deb http://www.deb-multimedia.org/ wheezy main non-free" >> /etc/apt/sources.list
  echo "deb-src http://www.deb-multimedia.org/ wheezy main non-free" >> /etc/apt/sources.list
fi

apt-get install -y --force-yes deb-multimedia-keyring
apt-get update && apt-get upgrade -y
apt-get install -y vim tmux build-essential python-dev python-pip gdb git

if [[ $rpi == 1 ]]
then
  apt-get install -y opencv-dev python-opencv python-picamera
  wget http://node-amr.herokuapp.com/node_latest_armhf.deb
  dpkg -i node_latest_armhf.deb
else
  bash opencv.sh
  git clone https://mpotok@bitbucket.org/mpotok/programs.git
  git clone --recursive https://mpotok@bitbucket.org/mpotok/projects.git
fi

echo "Linking files"
sudo -u $SUDO_USER ln -s ./.vim $homeDir/.vim
sudo -u $SUDO_USER ln -s ./.vimrc $homeDir/.vimrc
sudo -u $SUDO_USER ln -s ./.tmux.conf $homeDir/.tmux.conf
sudo -u $SUDO_USER ln -s ./.gitconfig $homeDir/.gitconfig
