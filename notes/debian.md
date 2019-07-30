TODO make sure all stuff is less that 80 width

# Debian

An outline of how to setup a fresh minimal Debian install.

## Setup Process

Steps to follow:
1. Change keyboard to programmer Dvorak (dvp) `dpkg-reconfigure keyboard configuration`
2. Install sudo `apt install git neovim sudo`
3. Add `<USER>` to sudoers via visudo `/usr/sbin'
4. Modify `/etc/apt/sources.list` from `<release>' to 'testing' and add `contrib non-free`
5. Modify grub to remember last choice
  1. GRUB\_DEFAULT=saved  
     GRUB\_SAVEDEFAULT=true
  3. Run `sudo update-grub` (may be in /usr/sbin)
6. Clone `dotfiles` repository and setup


New ones:
login to root and configure xorg: X -configure and then cp /root/xorg.conf.new
/etc/X11/xorg.conf

touchpad
Edit the /usr/share/X11/xorg.conf.d/40-libinput.conf file to include
    Option "Tapping" "on
