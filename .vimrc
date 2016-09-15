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
"Plugin 'c.vim'
Plugin 'justinmk/vim-syntax-extra'
Plugin 'octol/vim-cpp-enhanced-highlight'
Plugin 'hdima/python-syntax'
Plugin 'flazz/vim-colorschemes'

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

set textwidth=80
set formatoptions-=cro
set formatoptions+=t

"set t_ut=
set t_Co=256
colorscheme lucius
LuciusBlack
syntax on


let g:netrw_liststyle=3

"Language specific
"C-Lang
let g:cpp_class_scope_highlight=1 
let g_cpp_experimental_template_highlight=1

"Python
let python_highlight_all=1


au! FileType python setl nosmartindent
au BufRead,BufNewFile *.cl,*cu,*cuh set filetype=c
