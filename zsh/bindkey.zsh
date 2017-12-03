# Standard and additional keybindings:
#   ctrl + u     : clear line
#   ctrl + w     : delete word backward
#   alt  + d     : delete word
#   ctrl + a     : move to beginning of line
#   ctrl + e     : move to end of line (e for end)
#   alt/ctrl + f : move to next word (f for forward)
#   alt/ctrl + b : move to previous word (b for backward)
#   ctrl + d     : delete char at current position (d for delete)
#   ctrl + k     : delete from character to end of line
#   alt  + .     : cycle through previous args

# current selected match accepted in menu selection
bindkey -M menuselect '^M' .accept-line

# go backward in menu with shift-tab
bindkey '^[[Z' reverse-menu-complete

# alt-x: insert last command result
zmodload -i zsh/parameter
insert-last-command-output() {
  LBUFFER+="$(eval $history[$((HISTCMD-1))])"
}
zle -N insert-last-command-output
bindkey '^[x' insert-last-command-output

# ctrl+b/f or ctrl+lef/right: move word by word
bindkey '^b' backward-word
bindkey '^f' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

# ctrl-space: print git status
bindkey -s '^ ' 'git status --short^M'


# Accept and execute the current suggestion (using zsh-autosuggestions)
# Find the key with: showkey -a
# '^J': Ctrl+Enter
bindkey '^J' autosuggest-execute

# Disable flow control (ctrl+s, ctrl+q) to enable saving with ctrl+s in Vim
stty -ixon -ixoff
