#Linux utilities
alias ls='ls --color=auto'
alias ll='ls -l'
alias la='ls -a'
alias mkdir='mkdir -p'
alias df='df -h'
alias du='du -h'

#Navigation
alias back='cd $OLDPWD'
alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'
alias ......='cd ../../../../../'

#Directory shortcuts
alias home='cd'
alias documents='cd ~/Documents'
alias downloads='cd ~/Downloads'
alias programs='cd ~/Programs'
alias projects='cd ~/Projects'

#Typos
alias sl='ls'

#Apt
alias install='sudo apt-get install'
alias remove='sudo apt-get remove'
alias search='sudo apt-cache search'
alias show='sudo apt-cache show'
alias cleanup='sudo apt-get autoclean && sudo apt-get clean && sudo apt-get autoremove'

#Programs
alias chrome='google-chrome'
alias browser='google-chrome'
alias vi='vim'
alias edit='vim'
alias tmux='tmux -2'
