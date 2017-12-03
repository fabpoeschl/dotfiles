" General config {{{
set nocompatible

" default encoding
set encoding=utf-8

" set filetype stuff to on
filetype off
"}}}

" Vundle {{{
source ~/.vim/bundles.vim
" }}}
"
" Colors {{{
colorscheme badwolf
syntax enable
" }}}

" Spaces and Tabs {{{
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set autoindent
set smartindent

filetype indent on
filetype plugin on
" }}}

" UI Layout {{{
set number
set showcmd
set showmode
set nocursorline
set wildmenu   " visual autocomplete for command menu
set lazyredraw " redraw only when needed
set showmatch  " highlight matching [{()}]
"}}}

" Searching {{{
set ignorecase
set smartcase
set incsearch " search as characters are entered
set hlsearch  " highlight matches
set wrapscan
" }}}

" Folding {{{
set foldenable
set foldlevelstart=10
set foldnestmax=10
set foldmethod=indent
" space open/closes folds
nnoremap <space> za
" }}}

" Line shortcuts {{{
" turn off search highlight
nnoremap <leader><space> :nohlsearch<CR>
" move vertically by visual line
nnoremap j gj
nnoremap k gk
" highlight last inserted text
nnoremap gV `[v`]
" }}}

" Leader Shortcuts {{{
let mapleader=","
" jk is escape  
inoremap jk <esc>
" toggle gundo
nnoremap <leader>u :GundoToggle<CR>
" move to beginning/end of line
nnoremap B ^
nnoremap E $
" save session
nnoremap <leader>s :mksession<CR>
" ,c is Syntastic check
nnoremap <leader>c :SyntasticCheck<CR>:Errors<CR>
" }}}

" CtrlP {{{
let g:ctrlp_match_window = 'bottom,order:ttb'
let g:ctrlp_switch_buffer = 0
let g:ctrlp_working_path_mode = 0
let g:ctrlp_custom_ignore = '\vbuild/|dist/venv/|target/|\.(o|swp|pyc|egg)$'
" }}}

" Syntastic {{{
let g:syntastic_python_flake8_args='--ignore=E501'
let g:syntastic_ignore_files = ['.java$']
let g:syntastic_python_python_exec = 'python3'
" }}}

" Autogroups {{{
augroup configgroup
        autocmd!
        autocmd VimEnter * highlight clear SignColumn
        autocmd BufWritePre *.php,*.py,*.js,*.txt,*.java
                    \:call <SID>StripTrailingWhitespaces()
        autocmd FileType java setlocal list
        autocmd FileType java setlocal listchars=tab+\ ,eol:-
        autocmd FileType java setlocal formatprg=par\ -w80\ -T4
        autocmd FileType php setlocal expandtab
        autocmd FileType php setlocal list
        autocmd FileType php setlocal listchars=tab:+\ ,eol:-
        autocmd FileType php setlocal formatprg=par\ -w80\ -T4
        autocmd FileType ruby setlocal tabstop=2
        autocmd FileType ruby setlocal shiftwidth=2
        autocmd FileType ruby setlocal softtabstop=2
        autocmd FileType ruby setlocal commentstring=#\ %s
        autocmd Filetype python setlocal commentstring=#\ %s
        autocmd BufEnter *.zsh-theme setlocal filetype=zsh
        autocmd BufEnter Makefile setlocal noexpandtab
        autocmd BufEnter *.sh setlocal tabstop=2
        autocmd BufEnter *.sh setlocal shiftwidth=2
        autocmd BufEnter *.sh setlocal softtabstop=2
augroup END
" }}}

" Backups {{{
set backup
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set backupskip=/tmp/*,/private/tmp/*
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set writebackup
" }}}

" vim:foldmethod=marker:foldlevel=0
