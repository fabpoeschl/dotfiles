set nocompatible
filetype off

" for neovim plugins (rplugin)
if has('nvim')
  function! UpdateRemote(arg)
    if has_key(g:, 'did_plug_UpdateRemote') | return | endif
    let g:did_plug_UpdateDoRemote = 1
    UpdateRemotePlugins
  endfunction
endif

" Install vim-plug if we don't already have it
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()

" git
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" languages
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-rails'
Plug 'ekalinin/dockerfile.vim'
Plug 'plasticboy/vim-markdown'

" tools 
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }  " FZF plugin, makes Ctrl-P unnecessary
Plug 'junegunn/fzf.vim'

let g:_nerdtree_lazy_events = ['NERDTree', 'NERDTreeToggle', 'NERDTreeTabsToggle', '<Plug>NERDTreeTabsToggle']
Plug 'scrooloose/nerdtree', { 'on': g:_nerdtree_lazy_events }
Plug 'jistr/vim-nerdtree-tabs', { 'on': g:_nerdtree_lazy_events }
Plug 'szw/vim-maximizer'    " zoom and unzoom!
Plug 'sjl/gundo.vim'
Plug 'epmatsw/ag.vim'
if !has('nvim')
  Plug 'tpope/vim-dadbod'
  Plug 'kristijanhusak/vim-dadbod-ui'
else
  Plug 'dinhhuy258/vim-database', {'branch': 'master', 'do': ':UpdateRemotePlugins'}
endif

" code completion
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'w0rp/ale'
Plug 'tpope/vim-surround'
Plug 'MarcWeber/vim-addon-mw-utils'
Plug 'tomtom/tlib_vim'
Plug 'garbas/vim-snipmate'
Plug 'honza/vim-snippets'
Plug 'scrooloose/syntastic'

" colorschemes 
Plug 'morhetz/gruvbox'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

if has('nvim')
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
endif

call plug#end()
filetype plugin indent on
