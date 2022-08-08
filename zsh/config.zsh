#
# History
#
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
# share history between multiple terminal sessions
setopt share_history
# append history, instead of replace, when a terminal session exits
setopt appendhistory
# Add commands as they are typed, don't wait until shell exit
setopt inc_append_history
# ingore commands with a space before
setopt hist_ignore_space
# remove old entry and append new
setopt hist_ignore_all_dups
# don't display results already cycled through in search
setopt hist_find_no_dups
# remove extra blanks from each command being added to history
setopt hist_reduce_blanks
# add timestamps to history
setopt extended_history

#
# Options
#

# enable parameter expansion, command substition, and arithmetic expansion in prompt
set prompt_subst
# allow completion from within word/phrase
setopt complete_in_word
# move cursor to end of word when completing from middle
setopt always_to_end
# go to path if not a command
setopt autocd
# allow comments in interactive shells
setopt interactive_comments
# report status of background jobs immediately
setopt notify
# list jobs in long format
setopt long_list_jobs
# allow functions to have local options
setopt local_options
# allow functions to have traps
setopt local_traps
# alias tab completion
setopt complete_aliases

#
# ENV
#

export EDITOR='/usr/bin/vim'
export VISUAL='/usr/bin/vim'
export LESS='--ignore-case --RAW-CONTROL-CHARS --LONG-PROMPT --quit-if-one-screen --hilite-unread --tabs=4'
export LIBMYSQL_ENABLE_CLEARTEXT_PLUGIN=1
#eval $(lesspipe)

# print dates in isoformat
export TIME_STYLE=long-iso

#
# ZSH modules config
#

# force refresh the terminal title before each command
autoload add-zsh-hook
update_terminal_title() {
  print -Pn "\e]0;%~ - Terminal\a"
}
add-zsh-hook precmd update_terminal_title

# Awesome MV
# example: zmv '(**/)file.xml' '$1anotherName.xml'
autoload zmv

# edit command line by ctrl+x ctrl+e
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line

