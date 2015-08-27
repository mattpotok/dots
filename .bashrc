#--------------------
#Colors
#--------------------

# Reset
Color_Off='\e[0m'       # Text Reset

# Regular Colors
Black='\e[0;30m'        # Black Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White 
# Bold
BBlack='\e[1;30m'       # Black
BRed='\e[1;31m'         # Red
BGreen='\e[1;32m'       # Green
BYellow='\e[1;33m'      # Yellow
BBlue='\e[1;34m'        # Blue
BPurple='\e[1;35m'      # Purple
BCyan='\e[1;36m'        # Cyan
BWhite='\e[1;37m'       # White

# Underline
UBlack='\e[4;30m'       # Black
URed='\e[4;31m'         # Red
UGreen='\e[4;32m'       # Green
UYellow='\e[4;33m'      # Yellow
UBlue='\e[4;34m'        # Blue
UPurple='\e[4;35m'      # Purple
UCyan='\e[4;36m'        # Cyan
UWhite='\e[4;37m'       # White

# Background
On_Black='\e[40m'       # Black
On_Red='\e[41m'         # Red
On_Green='\e[42m'       # Green
On_Yellow='\e[43m'      # Yellow
On_Blue='\e[44m'        # Blue
On_Purple='\e[45m'      # Purple
On_Cyan='\e[46m'        # Cyan
On_White='\e[47m'       # White

# High Intensity
IBlack='\e[0;90m'       # Black
IRed='\e[0;91m'         # Red
IGreen='\e[0;92m'       # Green
IYellow='\e[0;93m'      # Yellow
IBlue='\e[0;94m'        # Blue
IPurple='\e[0;95m'      # Purple
ICyan='\e[0;96m'        # Cyan
IWhite='\e[0;97m'       # White

# Bold High Intensity
BIBlack='\e[1;90m'      # Black
BIRed='\e[1;91m'        # Red
BIGreen='\e[1;92m'      # Green
BIYellow='\e[1;93m'     # Yellow
BIBlue='\e[1;94m'       # Blue
BIPurple='\e[1;95m'     # Purple
BICyan='\e[1;96m'       # Cyan
BIWhite='\e[1;97m'      # White

# High Intensity backgrounds
On_IBlack='\e[0;100m'   # Black
On_IRed='\e[0;101m'     # Red
On_IGreen='\e[0;102m'   # Green
On_IYellow='\e[0;103m'  # Yellow
On_IBlue='\e[0;104m'    # Blue
On_IPurple='\e[0;105m'  # Purple
On_ICyan='\e[0;106m'    # Cyan
On_IWhite='\e[0;107m'   # White

#--------------------
#Default
#--------------------

#If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

#Editor
export EDITOR=vim
export VISUAL=vim

#History settings
export HISTCONTROL=ignoreboth
export HISTSIZE=1000
export HISTFILESIZE=2000

#Shell options
shopt -s histappend
shopt -s checkwinsize

#Make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

#Set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

#If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*|screen*)
    PS1="\[\e[1;90m\][\[\e[0;36m\]\u\[\e[1;90m\]@\[\e[0;36m\]\h\[\e[1;90m\]: \[\e[1;94m\]\W\[\e[1;90m\]]\[\e[0;32m\]$ "
    ;;
*)
    PS1='[\u@\h \W]\$ ' 
    ;;
esac

#Colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

#Alias definitions
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

#Bash completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


#--------------------
#Functions
#--------------------

#File extraction
function extract()
{
  if [ -f $1 ]; then
    case $1 in 
      *.tar.bz2)  tar xvjf $1    ;;
      *.tar.gz)   tar xvzf $1    ;;
      *.bz2)      bunzip2 $1     ;;
      *.rar)      unrar x $1     ;;
      *.gz)       gunzip $1      ;;
      *.tar)      tar xvf $1     ;;
      *.tgz)      tar xvzf $1    ;;
      *.zip)      unzip $1       ;;
      *.Z)        uncompress $1  ;;
      *.7z)       7z x $1        ;;
      *)          echo "Don't know how to extract '$1'..."  ;;
    esac
  else
    echo "'$1' is not a valid file!"
  fi
}

#Makes and cd into a directory
function mkcd()
{
  mkdir -p $1
  cd $1
}

#Create archive
function mktar() { tar cvf  "${1%%/}.tar"     "${1%%/}/"; }
function mktgz() { tar cvzf "${1%%/}.tar.gz"  "${1%%/}/"; }
function mktbz() { tar cvjf "${1%%/}.tar.bz2" "${1%%/}/"; }
function mkzip() { zip -r   "${1%%/}.zip"     "${1%%/}/"; }
function mkrar() { rar a    "${1%%/}.rar"     "${1%%/}/"; }


#--------------------
#Greeting
#--------------------

#clear
echo -e "${BICyan}                                 .--.      "
echo -e "${BICyan} ____    ___  _______           |o_o |     "
echo -e "${BICyan}|___ \  /   ||____  /           |:_/ |     "
echo -e "${BICyan} | |\ \/ /| | ___/ /           //   \ \    "
echo -e "${BICyan} | | \_\/ | ||____/           (|     | )   "
echo -e "${BICyan} | |      | |                /'\_   _/\`\  "
echo -e "${BICyan} |_|      |_|                \___)=(___/   "; echo ""
echo -e "${BIBlue}Today is:\t${BIGreen} `date`";
echo -e "${BIBlue}Kernel info:\t${BIGreen} `uname -smr`"
echo -e "${BIBlue}Uptime:\t\t${BIGreen} `uptime -p`"; echo ""
