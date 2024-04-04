set nocompatible
let vimPlug=1
let vimPlugPath=expand('~/.vim/autoload/plug.vim')
if !filereadable(vimPlugPath)
  echo "Installing vimPlug..."
  silent !curl -sSfLo ~/.vim/autoload/plug.vim --create-dirs 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  let vimPlug=0
endif
filetype off

call plug#begin()
Plug 'tomasr/molokai'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'sheerun/vim-polyglot'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/nerdcommenter'
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
call plug#end()

if vimPlug == 0
  echo "Installing Plugins, please ignore key map error messages"
  :PlugInstall
endif

colorscheme molokai
filetype plugin on
filetype indent on
syntax enable

set backspace=2
set clipboard=unnamed
set cursorline
set encoding=utf8
set expandtab
set ignorecase
set incsearch
set nobomb
set number
set ruler
set shiftwidth=2
set showmatch
set softtabstop=2
set t_Co=256
set tabstop=2
set termencoding=utf8

let g:molokai_original=1

let g:NERDSpaceDelims=1

let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1

let g:go_fmt_command = 'goimports'

nmap <F1> :NERDTreeToggle<CR>
nmap <silent> <F2> :tabp <CR>
nmap <silent> <F3> :tabn <CR>
nmap <F4> :set nonumber!<CR>:set foldcolumn=0<CR>
nmap <F12> gg=G''<CR>

map <C-n> :cnext<CR>

autocmd FileType go nmap <leader>r  <Plug>(go-run)
autocmd FileType go nmap <leader>b  <Plug>(go-build)
autocmd FileType go nmap <leader>t  <Plug>(go-test)
autocmd FileType go nmap <leader>c <Plug>(go-coverage)
autocmd FileType go.python setlocal shiftwidth=4 softtabstop=4

