alias szshrc='source ~/.zshrc'
alias f='find -iname'
alias v='vim'
alias up="sudo apt update && sudo apt -V --yes upgrade"

# history with timestamps and elapsed time
alias h='history -iD'

# ls
# -v: natural sort of version
alias ls='ls                                  -v --classify --group-directories-first --color=auto'
alias  l='ls -l              --human-readable -v --classify --group-directories-first --color=auto'
alias ll='ls -l              --human-readable -v --classify --group-directories-first --color=auto'
alias la='ls -l --almost-all --human-readable -v --classify --group-directories-first --color=auto'

# grep
alias  grep='grep --color=auto'
alias egrep='grep --color=auto'
alias zgrep='grep --color=auto'

# More verbose fileutils
alias cp='nocorrect cp -iv' # -i to prompt for every file
alias mv='nocorrect mv -iv'
alias rm='nocorrect rm -Iv' # -I to prompt when more than 3 files
alias rmdir='rmdir -v'
alias chmod='chmod -v'
alias chown='chown -v'

# Parent directories
alias cd..='cd ..'
alias '..'='cd ..'
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'
alias -g .......='../../../../../..'

# Git
alias g='git'
compdef g=git
alias gst='git status'
alias gl='git log'
alias gp='git pull'
alias gaa='git add -A'
alias gc='git commit'

