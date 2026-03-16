alias szshrc='source ~/.zshrc'
# use fd if available, fall back to find
if command -v fd &>/dev/null; then
  alias f='fd -i'
elif command -v fdfind &>/dev/null; then
  alias f='fdfind -i'
else
  alias f='find -iname'
fi
alias v='vim'
alias up="sudo apt update && sudo apt -V --yes upgrade"

# history with timestamps and elapsed time
alias h='history -iD'

# ls - use eza if available, fall back to ls
if command -v eza &>/dev/null; then
  alias ls='eza --classify --group-directories-first'
  alias  l='eza -l --group-directories-first'
  alias ll='eza -l --group-directories-first'
  alias la='eza -la --group-directories-first'
  alias lt='eza -l --tree --level=2 --group-directories-first'
else
  case "$(uname -s)" in
    Darwin*) _list_cmd=gls;;
    *)       _list_cmd=ls;;
  esac
  alias ls="${_list_cmd} -v --classify --group-directories-first --color=auto"
  alias  l="${_list_cmd} -l --human-readable -v --classify --group-directories-first --color=auto"
  alias ll="${_list_cmd} -l --human-readable -v --classify --group-directories-first --color=auto"
  alias la="${_list_cmd} -l --almost-all --human-readable -v --classify --group-directories-first --color=auto"
fi

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

# Podman as Docker drop-in
alias docker='podman'
alias docker-compose='podman-compose'

# bat (syntax-highlighted cat)
if command -v bat &>/dev/null; then
  alias cat='bat --paging=never'
elif command -v batcat &>/dev/null; then
  alias cat='batcat --paging=never'
fi
