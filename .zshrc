#---------#
# Aliases #
#---------#
if [[ -r 

#--------#
# Colors #
#--------#
# Create a separate file for this


# TODO: completed
#-----------#
# Directory #
#-----------#
DIRSTACKSIZE=16           # Set the directory stack size
alias ds='dirs -v'        # Alias director stack
setopt AUTO_CD            # 'cd' without the cd
setopt AUTO_PUSHD         # Automatically push 'cds' unto stack
setopt PUSHD_IGNORE_DUPS  # Prevent duplicates from being pushed
setopt PUSHD_MINUS        # Swap meanings of '-' and '+'
setopt PUSHD_SILENT       # Push silently unto the stack
setopt PUSHD_TO_HOME      # Allow $HOME to be pushed


# TODO: completed
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

#--------------#
# Key bindings #
#--------------#
bindkey -v  # Enable Vi keybindings


#---------#
# Modules #
#---------#
autoload -Uz compinit
compinit

#--------#
# Prompt #
#--------#


#---------#
# Welcome #
#---------#
clear
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
