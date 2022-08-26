" General config {{{
set nocompatible

" default encoding
set encoding=utf-8

" set filetype stuff to on
filetype off

" }}}

" Plugins {{{
source ~/.vim/plugins.vim
" }}}
"
" Colors {{{
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

" Tab shortcuts {{{
nnoremap <C-t> :tabnew<CR>
nnoremap th  :tabfirst<CR>
nnoremap tk  :tabnext<CR>
nnoremap tj  :tabprev<CR>
nnoremap tl  :tablast<CR>
nnoremap tt  :tabedit<Space>
nnoremap tn  :tabnext<Space>
nnoremap tm  :tabm<Space>
nnoremap td  :tabclose<CR>
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
" move to beginning/end of line
nnoremap B ^
nnoremap E $
" save session
nnoremap <leader>s :mksession<CR>
" ,c is Syntastic check
nnoremap <leader>c :SyntasticCheck<CR>:Errors<CR>

" <leader>{y,x,p} : {yank,cut,paste} wrt the system clipboard
map <leader>y "*y
noremap <leader>x "*x
noremap <leader>p "*p

" <leader>w : save
nnoremap <leader>w :w!<CR>

" <leader>q : quit/close window
nnoremap <silent> <leader>q :q<CR>

" <leader>S : Strip trailing whitespaces
command! -nargs=0 Strip call StripTrailingWhitespaces()
nnoremap <leader>S :Strip<CR>

" Surround a word with quotes, single quotes, parens, brackets, braces, etc.
"   requires and powered by the plugin surround.vim :-)
" (Note) for visual blocks, use S command from surround.vim
nmap  <leader>s" ysiw"
nmap  <leader>s' ysiw'
nmap  <leader>s` ysiw`
nmap  <leader>s* ysiw*l
nmap  <leader>s_ ysiw_l
nmap  <leader>s~ ysiw~l
nmap  <leader>s$ ysiw$
nmap  <leader>s( ysiw(
nmap  <leader>s) ysiw)
nmap  <leader>s[ ysiw[
nmap  <leader>s] ysiw]
nmap  <leader>s{ ysiw{
nmap  <leader>s} ysiw}

" <leader>df : diffthis
nnoremap <leader>df :diffthis<CR>
" }}}

" System Clipboard {{{
set clipboard=unnamed
nnoremap <C-c> "+y
vnoremap <C-c> "+y
" }}}

" FZF {{{
nnoremap <silent> <C-p> :FZF<CR>
" }}}

" {{{ Airline
autocmd User AirlineAfterInit call AirlineSectionInit()
function! AirlineSectionInit()
  " define minwidth for some parts
  call airline#parts#define_minwidth('branch', 120)

  " section b: git info (need to call again after define_minwidth/branch)
  let g:airline_section_b = airline#section#create(['hunks', 'branch'])

  " section c:
  let g:airline_section_c = airline#section#create([
        \ '%<', 'file', g:airline_symbols.space, 'readonly',
        \ ])

  " LSP support (this should run after those plugin has been initialized)
  if exists(':LspStatus')  | call airline#parts#define_function('lsp_status', 'AirlineLspStatus') | endif

  " section y: +lsp status, -filetype
  let g:airline_section_x = airline#section#create_right([
        \ 'lsp_status',
        \ 'bookmark', 'tagbar', 'vista', 'gutentags', 'grepper',
        \ ])               " excludes filetype

endfunction

" airline + lsp-status
function! AirlineLspStatus() abort
  return v:lua.LspStatus()
endfunction


" section y (ffenc): skip if utf-8[unix]
let g:airline#parts#ffenc#skip_expected_string = 'utf-8[unix]'

" section z: current position, but more concisely
let g:airline_section_z = 'L%3l:%v'

" }}}

" enable tabline feature
let g:airline#extensions#tabline#enabled = 1

" disable tagbar (in favor of LSP)
let g:airline#extensions#tagbar#enabled = 0

" Display buffers (like tabs) in the tabline
" if there is only one tab
let g:airline#extensions#tabline#show_buffers = 1

" suppress mixed-indent warning for javadoc-like comments (/** */)
let g:airline#extensions#whitespace#mixed_indent_algo = 1
" }}}

" bind K to grep word under cursor
nnoremap K :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>

" Syntastic {{{
let g:syntastic_python_flake8_args='--ignore=E501'
let g:syntastic_ignore_files = ['.java$']
let g:syntastic_python_python_exec = 'python3'
" }}}

" Backups {{{
" no fucking swap and backup files
set noswapfile
set nobackup
" }}}

" SnipMate {{{
let g:snipMate = { 'snippet_version' : 1 }
" }}}

" gundo key mappings and options {{{
let g:gundo_right = 1   " show at right
nnoremap <leader>G :GundoToggle<CR>
" }}}

" dictionary
if filereadable('/usr/share/dict/words')
  set dictionary+=/usr/share/dict/words
endif

" Retain more history (:, search strings, etc.)
set history=10000
set undolevels=1000

" miscellanious
set visualbell
set lazyredraw              " no redrawing during macro execution

" Make gitgutter signs, etc. be more responsive (default is 4000ms)
set updatetime=200

set matchpairs+=<:>

" CTags {{{
" Set f5 to generate tags for non-latex files
augroup TexTags
  autocmd! TexTags
  autocmd FileType tex let b:latex=1
augroup end 
if !exists("b:latex")
    nnoremap <f5> :!ctags -R<CR>
endif

set tags=./.tags;$HOME
" }}}

" Custom Functions {{{

" toggle between number a nd relativenumber
function! ToggleNumber()
    if(&relativenumber == 1)
        set norelativenumber
        set number
    else
        set relativenumber
    endif
endfunc

" strips trailing whitespace at the end of files. this
" is called on buffer write in the autogroup above.
function! StripTrailingWhitespaces()
    " save last search & cursor position
    let _s=@/
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    let @/=_s
    call cursor(l, c)
endfunction
" }}}

" COC {{{
let g:coc_global_extensions = ['coc-solargraph']

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file.
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1):
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
" }}}

" vim:foldmethod=marker:foldlevel=0
