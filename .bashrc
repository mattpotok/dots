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

#Color prompt
force_color_prompt=yes
if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

#PS1 prompt
if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

#If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

#Enable color support of ls and also add handy aliases
#Move this into bash_alias
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
fi

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
