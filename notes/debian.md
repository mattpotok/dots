# Debian

An outline of how to setup a fresh minimal Debian install.

## Setup Process

Steps to follow:
1. Configure keyboard:
   ```sh
   setxkbmap \
       -model 'pc105' \
       -layout 'us(dvp),us' \
       -option 'grp:win_space_toggle' \
       -option 'caps:escape'
   ```
2. Install minimal set of packages: `sudo apt install git neovim sudo`
3. Add `$USER` to sudoers with `sudo visudo` (may be in /usr/sbin)
4. Modify `/etc/apt/sources.list` from `<release>` to `testing`
   and add `contrib non-free`
5. Modify grub to remember last choice
  1. GRUB\_DEFAULT=saved
     GRUB\_SAVEDEFAULT=true
  2. Run `sudo update-grub` (may be in /usr/sbin)
6. Clone `dotfiles` repository and setup

## TODO

New ones:
login to root and configure xorg: X -configure and then cp /root/xorg.conf.new
/etc/X11/xorg.conf

touchpad
Edit the /usr/share/X11/xorg.conf.d/40-libinput.conf file to include
    Option "Tapping" "on
