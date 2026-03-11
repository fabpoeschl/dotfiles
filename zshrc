# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# zgenom (successor to zgen, backwards-compatible)
source "${HOME}/.zsh/zgenom/zgenom.zsh"
if ! zgenom saved; then
  echo "Creating a zgenom save"

  zgenom load zsh-users/zsh-autosuggestions
  zgenom load zsh-users/zsh-syntax-highlighting
  zgenom oh-my-zsh plugins/history-substring-search
  zgenom oh-my-zsh plugins/sudo
  zgenom oh-my-zsh plugins/httpie
  zgenom oh-my-zsh plugins/command-not-found
  zgenom load zsh/complist
  zgenom load zsh-users/zsh-completions src
  zgenom load olivierverdier/zsh-git-prompt
  zgenom load chrissicool/zsh-256color
  zgenom load johnhamelink/env-zsh
  zgenom load theunraveler/zsh-fancy_ctrl_z
  zgenom load romkatv/powerlevel10k powerlevel10k
  
  zgenom save
fi

ZSH_BASE_DIR="${HOME}/.zsh"
if [[ -d "$ZSH_BASE_DIR" ]]; then
  for file in "$ZSH_BASE_DIR"/*.zsh; do
    source "$file"
  done
  unset file
fi

ZSH_FUNCTIONS_DIR="${ZSH_BASE_DIR}/functions"
if [[ -d "$ZSH_BASE_DIR" ]]; then
  for file in "$ZSH_FUNCTIONS_DIR"/*.zsh; do
    source "$file"
  done
  unset file
fi

# try to include all sources
foreach file (`echo $sources`)
    if [[ -a $file ]]; then
        # sourceIncludeTimeStart=$(gdate +%s%N)
        source $file
        # sourceIncludeDuration=$((($(gdate +%s%N) - $sourceIncludeTimeStart)/1000000))
        # echo $sourceIncludeDuration ms runtime for $file
    fi
end

if [ -f ~/.zshrc.local ]; then
  source ~/.zshrc.local
fi

# rbenv init
eval "$(rbenv init - zsh)"

# nvm init (manages Node versions - no hardcoded node path needed)
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

ulimit -Sn 10240

# PATH additions (rbenv is initialized above via eval; pyenv shims added if available)
export PATH="$PATH:/opt/homebrew/Cellar/jemalloc"
command -v pyenv &>/dev/null && export PATH="$PATH:$(pyenv root)/shims"

# zoxide (smart cd replacement)
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
