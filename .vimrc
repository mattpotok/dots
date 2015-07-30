"--------------------
"Vundle
"--------------------

set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

"Plugins
Plugin 'gmarik/Vundle.vim'
Plugin 'christoomey/vim-tmux-navigator'

"Syntax & Color
Plugin 'wting/rust.vim'
Plugin 'justinmk/vim-syntax-extra'

call vundle#end()
filetype plugin indent on


"--------------------
"Configuration
"--------------------

set autoindent
set smartindent
set expandtab
set tabstop=2
set shiftwidth=2
set number
set numberwidth=1
set t_ut=
set t_Co=256
colorscheme oceannight
syntax on

let g:netrw_liststyle=3

"Language specific
au! FileType python setl nosmartindent
au BufRead,BufNewFile *.cl,*cu,*cuh set filetype=c
