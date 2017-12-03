zmodload -i zsh/complist

# enable completion cashing, use rehash to clear
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# name of tag for matches will be used as group name
zstyle ':completion:*' group-name ''

# menu friendly
zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'

# with a lot of choices
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'

# completion menu
# 'select=num', menu selection will only be started with at least num matches
zstyle ':completion:*' menu select=2 _complete _ignored _approximate
zstyle ':completion:*::::' completer _expand _complete _ignored _approximate
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# colors
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*:original' list-colors "=*=$color[red];$color[bold]"
zstyle ':completion:*:parameters' list-colors "=[^a-zA-Z]*=$color[red]"
zstyle ':completion:*:aliases' list-colors "=*=$color[green]"

# avoid twice same element on rm
zstyle ':completion:*:rm:*' ignore-line yes

# sudo completion if command is not in current path
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin /usr/X11R6/bin
