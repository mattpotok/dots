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
2. Edit `/etc/X11/xorg.conf.d/*-libinput.conf` to enable touchpad tapping:
   ```
    Option "Tapping" "on
   ```
   Restart Xorg (or computer) for changes to take effect.
3. Install minimal set of packages: `sudo apt install git neovim sudo`
4. Add `$USER` to sudoers with `sudo visudo` (may be in /usr/sbin)
5. Modify `/etc/apt/sources.list` from `<release>` to `testing`
   and add `contrib non-free`:
   ```
   deb <MIRROR (debian)> testing main contrib non-free
   deb-src <MIRROR (debian)> testing main contrib non-free

   deb <MIRROR (debian-security)> testing main contrib non-free
   deb-src <MIRROR (debian-security)> testing main contrib non-free
   ```
6. Modify grub to remember last choice:
   ```
   GRUB\_DEFAULT=saved
   GRUB\_SAVEDEFAULT=true
   ```
  Run `sudo update-grub` to save modifications (may be in /usr/sbin).
7. Install Firefox:
 1. Download desired version from the website (and possibly `scp` over)
 2. Extract it with `tar -jxvf`
 3. Move it `sudo cp ~/Downloads/firefox /opt/firefox`
 4. Add a symlink `sudo ln -s /opt/firefox/firefox /usr/local/bin/firefox`
 5. Install missing dependencies if necessary (libdbus-glib-1-2)
8. Clone `dotfiles` repository and setup

## Potential Issues

A list of issues encountered when setting up a fresh install and their
solutions:
* Issue: Missing firmware `failed to load i915/kbl-dmc_ver1_04.bin`
  Solution: `sudo apt install firmware-misc-nonfree`
* Issue with bluetooth at boot time:
  ```
  Bluetooth: hci0: command 0xfc09 tx timeout
  Bluetooth: hci0: Failed to send firmawer data (-X)
  Bluetooth: hci0: sending frame failed (-Y)
  ```
  Solution: If `connmanctl` is installed, run `connmanctl enable bluetooth`

## TODO

New ones:
login to root and configure xorg: X -configure and then cp /root/xorg.conf.new
/etc/X11/xorg.conf
