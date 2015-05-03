#!/bin/bash

#Installs packages and sets up the symbolic links
#Types of installs: 1 (minimal), 2 (full), 3 (RaspPi minimal), 4 (RaspPi full)

if [[ $UID != 0 ]]
then
  echo "Please run this script with sudo:"
  echo "sudo $0"
  exit 1
fi

#Prompting for install type
echo "Choose install type: 1 (minimal), 2 (full), 3 (RaspPi minimal), 4 (RaspPi full"
read installType

echo $installType
if ! [[ $installType == +([0-9]) ]] 
then
  echo "Invalid input"
  exit 1
elif ! [[ $installType -ge 1 && $installType -le 4 ]]
then
  echo "Invalid input"
  exit 1
fi


#INITIALIZE THE REMAINING VARS HERE!
homeDir="/home/$SUDO_USER"

echo "Installing packages"
if [[ $installType == 4 ]]
then
  wget http://www.linux-projects.org/listing/uv4l_repo/lrkey.asc && sudo apt-key add ./lrkey.asc
  echo "deb http://www.linux-projects.org/listing/uv4l_repo/raspbian/ wheezy main" >> /etc/apt/sources.list
else
  echo "deb http://www.deb-multimedia.org/ wheezy main non-free" >> /etc/apt/sources.list
  echo "deb-src http://www.deb-multimedia.org/ wheezy main non-free" >> /etc/apt/sources.list
  apt-get install -y --force-yes deb-multimedia-keyring
fi

apt-get update && apt-get upgrade -y
apt-get install -y vim tmux build-essential python-dev python-pip gdb git

if [[ $installType == 2 ]]
then
  ./opencv.sh
  git clone https://mpotok@bitbucket.org/mpotok/programs.git
  git clone --recursive https://mpotok@bitbucket.org/mpotok/projects.git
elif [[ $installType == 4 ]]
then
  apt-get install -y libopencv-core-dev python-opencv python-picamera autoconf
  wget http://node-arm.herokuapp.com/node_latest_armhf.deb
  dpkg -i node_latest_armhf.deb
  git clone https://github.com/sarfata/pi-blaster.git
  cd pi-blaster && ./autogen && ./configure && make && sudo make install && cd ..
  #Setting up pi camera
  apt-get install libjpeg8-dev imagemagick libv4l-dev uv4l uv4l-raspicam uv4l-raspicam-extras
  ln -s /usr/include/linux/videodev2.h /usr/include/linux/videodev.h
   wget http://sourceforge.net/code-snapshots/svn/m/mj/mjpg-streamer/code/mjpg-streamer-code-182.zip
   unzip mjpg-streamer-code-182.zip
   cd mjpg-streamer-code-182/mjpg-streamer
   make mjpg_streamer input_file.so output_http.so input_uvc.so
   cp mjpg_streamer /usr/local/bin
   cp output_http.so input_file.so /usr/local/lib/
   cp -R www /usr/local/www
   cd ../../
   rm -rf mjpg-streamer-182
fi

echo "Linking files"
sudo -u $SUDO_USER ln -s $homeDir/.dotfiles/.vim $homeDir/.vim
sudo -u $SUDO_USER ln -s $homeDir/.dotfiles/.vimrc $homeDir/.vimrc
sudo -u $SUDO_USER ln -s $homeDir/.dotfiles/.bash_aliases $homeDir/.bash_aliases
sudo -u $SUDO_USER ln -s $homeDir/.dotfiles/.tmux.conf $homeDir/.tmux.conf
sudo -u $SUDO_USER ln -s $homeDir/.dotfiles/.gitconfig $homeDir/.gitconfig
