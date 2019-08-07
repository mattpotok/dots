#!/bin/sh
#
# Configures and setups a new machine.

###################
# Global variables
###################
HELP=false

I3=false
PERSONAL=false
TMUX=false
VIM=false
ZSH=false

###########################
# usage()
# Prints a helpful message
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
###########################
usage()
{
cat <<'USAGE'
Usage: sudo ./setup [OPTIONS]
Setups device by installing packages, copying configuration files, and
setting environment variables.

Options:
  -h, --help        Display this help and exit.
  -i, --install     Installs specified packages. Select from
                      [all, development, personal, tmux, vim, zsh]
USAGE
}

########################################################
# setup_packages()
# Setups specified packages
# Globals:
#   I3          - flag to setup I3
#   PERSONAL    - flag to setup stuff for personal usage
#   TMUX        - flag to setup tmux
#   VIM         - flag to setup vim
#   ZSH         - flag to setup zsh
# Arguments:
#   None
# Returns:
#   None
########################################################
setup_packages()
{
    # Install general packages
    printf "Installing general packages\n"

    apt update && apt full-upgrade -y
    apt install -y build-essential cmake gdb git
    apt install -y python3-dev python3-pip

    # Install I3
    if [ $I3 = true ]; then
        _setup_i3
    fi

    # Install personal packages
    if [ $PERSONAL = true ]; then
        _setup_personal
    fi

    # Install tmux
    if [ $TMUX = true ]; then
        _setup_tmux
    fi

    # Install vim
    if [ $VIM = true ]; then
        #_setup_vim  FIXME
        _setup_nvim
    fi

    # Install zsh
    if [ $ZSH = true ]; then
        _setup_zsh
    fi
}

#############
# _setup_i3
# Sets up I3
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#############
_setup_i3()
{
    printf "Setting up I3.\n"

    # Install packages
    apt install -y i3 xbacklight xorg arandr

    # TODO create an I3 config
su $SUDO_USER <<'USER'
    # Copy configuration files
    cp $HOME/.dotfiles/x11/xinitrc $HOME/.xinitrc
    cp $HOME/.dotfiles/x11/Xresources $HOME/.Xresources
USER
}

#########################
# _setup_personal
# Sets up personal stuff
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#########################
_setup_personal()
{
    printf "Setting up personal packages.\n"

    # Install packages
    apt install -y keychain vlc

su $SUDO_USER <<'USER'
    # Copy configuration
    cp $HOME/.dotfiles/misc/gitconfig $HOME/.gitconfig
USER
}

###############
# _setup_tmux
# Sets up tmux
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
###############
_setup_tmux()
{
    printf "Setting up tmux.\n"

    # Install packages
    apt install -y tmux

su $SUDO_USER <<'USER'
    # Copy configuration
    cp $HOME/.dotfiles/misc/tmux.conf $HOME/.tmux.conf
USER
}

##############
# _setup_vim
# Sets up vim
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
##############
_setup_vim()
{
    printf "Setting up vim.\n"

    # Install packages
    apt install -y vim-nox

su $SUDO_USER <<'USER'
    # Copy configuration
    cp $HOME/.dotfiles/vim/vimrc $HOME/.vimrc

    # Setup vim plugins
    mkdir -p $HOME/.vim/bundle
    git clone https://github.com/gmarik/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
    vim +PluginInstall +qall
    $HOME/.vim/bundle/youcompleteme/install.py --clang-completer
USER
}

##############
# _setup_neovim
# Sets up vim
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
##############
_setup_nvim()
{
    printf "Setting up Neovim.\n"

    # Install packages
    apt install -y neovim

    apt install -y clang-tools
    apt install -y python3-pyflakes python3-pycodestyle python3-pydocstyle


su $SUDO_USER <<'USER'
    # Install language specific packages
    python3 -m pip install pyls

    curl https://sh.rustup.rs -sSf | sh 
    source $HOME/.cargo/env
    rustup update
    rustup component add rls rust-analysis rust-src

    # Copy configuration
    mkdir -p $HOME/.config/nvim
    cp $HOME/.dotfiles/config/nvim/init.vim $HOME/.config/nvim/init.vim

    # Setup plugins
    nvim +PlugInstall +qall
USER
}

##############
# _setup_zsh
# Sets up zsh
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
##############
_setup_zsh()
{
    printf "Setting up zsh.\n"

    # Install packages
    apt install -y zsh

su $SUDO_USER <<'USER'
    # Copy configuration
    cp $HOME/.dotfiles/zsh/zshenv $HOME/.zshenv
    cp $HOME/.dotfiles/zsh/zprofile $HOME/.zprofile
    cp $HOME/.dotfiles/zsh/zshrc $HOME/.zshrc
     
    # Remove bash clutter
    rm $HOME/.bash* 2> /dev/null
    rm $HOME/.profile 2> /dev/null

    # Change shell
    chsh -s $(which zsh)
USER
}

##############################################
# main
# Parses arguments and sets flags accordingly
##############################################
# Check for sudo permissions
if [ $(id -u) -ne 0 ]; then
    usage
    exit 0
fi

# Parse arguments
while true; do
    case "$1" in
        -h | --help)
            HELP=true; shift ;;
        
        -i | --install)
            case "$2" in
                all)
                    I3=true; PERSONAL=true; TMUX=true; VIM=true; ZSH=true ;;
                development)
                    TMUX=true; VIM=true; ZSH=true ;;
                i3)
                    I3=true ;;
                personal)
                    PERSONAL=true ;;
                tmux)
                    TMUX=true ;;
                vim)
                    VIM=true ;;
                zsh)
                    zsh=true ;;
                *)
                    HELP=true ;;
            esac
            shift 2
            ;;

        *)
            break ;;
    esac
done

# Print help message
if [ $HELP = true ]; then
    usage
    exit 0
fi

# Setup packages
setup_packages
