# Testing

function parse_git_branch {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
    echo "("${ref#refs/heads/}")"
}

#---------#
# Aliases #
#---------#
alias ds='dirs -v'        # Alias director stack


#-----------#
# Directory #
#-----------#
DIRSTACKSIZE=16           # Set the directory stack size

setopt AUTO_CD            # 'cd' without the cd
setopt AUTO_PUSHD         # Automatically push 'cds' unto stack
setopt PUSHD_IGNORE_DUPS  # Prevent duplicates from being pushed
setopt PUSHD_MINUS        # Swap meanings of '-' and '+'
setopt PUSHD_SILENT       # Push silently unto the stack
setopt PUSHD_TO_HOME      # Allow $HOME to be pushed


#-----------#
# Functions #
#-----------#


#---------#
# History #
#---------#
HISTFILE=~/.histfile        # History file location 
HISTSIZE=10000              # History size
SAVEHIST=10000              # History size

setopt HIST_IGNORE_ALL_DUPS # Prevent duplicates by removing older repeats
setopt HIST_IGNORE_SPACE    # Ignore all commands starting with a space
setopt HIST_REDUCE_BLANKS   # Remove superfluous blanks from command
setopt SHARE_HISTORY        # Share history among all sessions

# TODO fix the deletion issue
#--------------#
# Key bindings #
#--------------#
bindkey -v  # Enable Vi keybindings


#---------#
# Modules #
#---------#
autoload -Uz colors compinit
colors
compinit


#--------#
# Prompt #
#--------#
fgbk="$fg_bold[black]"
fgbl="$fg_bold[blue]"
fgbg="$fg_bold[green]"
fgc="$fg_no_bold[cyan]"
fgg="$fg_no_bold[green]"

PROMPT="%{$fgbk%}[%{$fgc%}%n%{$fgbk%}@%{$fgc%}%m%{$fgbk%}: \
%{$fgbl%}%1~%{$fgbk%}]%{$fgbg%}\$(parse_git_branch)%b%{$reset_color%}$ "

setopt PROMPT_SUBST


#-----------#
# Usability #
#-----------#
setopt ALWAYS_TO_END    # Move cursor to end after completion
setopt COMPLETE_IN_WORD # Enable mid-word completion
setopt CORRECT          # Correct the spelling of commands
setopt CORRECT_ALL      # Correct the spelling of all arguments
setopt DVORAK           # Set keyboard for spelling
setopt EXTENDED_GLOB    # Treat '#', '~', and '^' as part of path
setopt MULTIOS          # Allow for multiple redirection
                        
setopt NO_BEEP          # Disable beeping
setopt NO_CASE_GLOB     # Case insensitive globbing
setopt NO_FLOW_CONTROL  # Reclaim ^S/^Q

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case insensitive
 

#---------#
# Welcome #
#---------#
clear
echo -e "$fg_bold[cyan]                                 .--.      "
echo -e "$fg_bold[cyan] ____    ___  _______           |o_o |     "
echo -e "$fg_bold[cyan]|___ \  /   ||____  /           |:_/ |     "
echo -e "$fg_bold[cyan] | |\ \/ /| | ___/ /           //   \ \    "
echo -e "$fg_bold[cyan] | | \_\/ | ||____/           (|     | )   "
echo -e "$fg_bold[cyan] | |      | |                /'\_   _/\`\  "
echo -e "$fg_bold[cyan] |_|      |_|                \___)=(___/  \n"
echo -e "$fg_bold[blue]Today is:\t$fg_bold[green]`date`";
echo -e "$fg_bold[blue]Kernel info:\t$fg_bold[green]`uname -smr`"
echo -e "$fg_bold[blue]Uptime:\t\t$fg_bold[green]`uptime -p`\n"
