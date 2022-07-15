alias szshrc='source ~/.zshrc'
alias f='find -iname'
alias v='vim'
alias up="sudo apt update && sudo apt -V --yes upgrade"

# history with timestamps and elapsed time
alias h='history -iD'

# ls
# -v: natural sort of version
case "$(uname -s)" in
	Darwin*) listCmd=gls;;
	Linux*)  listCmd=ls;;
	*)       listCmd=ls;;
esac
 
alias ls='${listCmd} -v --classify --group-directories-first --color=auto'
alias  l='${listCmd} -l --human-readable -v --classify --group-directories-first --color=auto'
alias ll='${listCmd} -l --human-readable -v --classify --group-directories-first --color=auto'
alias la='${listCmd} -l --almost-all --human-readable -v --classify --group-directories-first --color=auto'

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

# Bundle
alias be='bundle exec'

# OpenShift
alias oc-mongo='POD_NAME=$(oc get pods | grep api | head -n1 | cut -d" " -f 1) && oc port-forward $POD_NAME $LOCAL_PORT:27017'
alias oc-mongo-dev='POD_NAME=$(oc get pods | grep mongo-36 | cut -d" " -f 1) && oc port-forward $POD_NAME $LOCAL_PORT:27017'
alias oc-mysql='POD_NAME=$(oc get pods | grep mysql | cut -d" " -f 1) && oc port-forward $POD_NAME 3305:3306'
alias oc-mongo-prd-billing='LOCAL_PORT=27016 && oc project prd-billing && oc-mongo'
alias oc-mongo-prd-apple='LOCAL_PORT=27015 && oc project prd-apple-premium-adapter && oc-mongo'
alias oc-mongo-prd-google='LOCAL_PORT=27014 && oc project prd-google-premium-adapter && oc-mongo'
alias oc-mongo-stg-billing='LOCAL_PORT=27016 && oc project stg-billing && oc-mongo'
alias oc-mongo-prd-rewards='LOCAL_PORT=27013 && oc project prd-premium-rewards && oc-mongo'
alias oc-mongo-stg-apple='LOCAL_PORT=27015 && oc project stg-apple-premium-adapter && oc-mongo'
alias oc-mongo-stg-google='LOCAL_PORT=27014 && oc project stg-google-premium-adapter && oc-mongo'
alias oc-mongo-stg-rewards='LOCAL_PORT=27013 && oc project stg-premium-rewards && oc-mongo'
alias oc-mongo-premium-dev='LOCAL_PORT=27011 && oc project dev-premium-dev && oc-mongo-dev'

# Docker
alias start-docker-machine='docker-machine start && eval "$(docker-machine env default)"'
