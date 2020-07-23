" Editor settings
set backspace=eol,indent,start  " Allow backspace over everything
set formatoptions-=cro          " Disable automatic comment insertion
set fo+=t                       " Auto-wrap text using textwidth
set number                      " Display line numbers
set numberwidth=3               " Width of number column
set splitbelow                  " Split (vertical)  new files below
set splitright                  " Split (horizontal) new files right
set textwidth=80                " Width of the text

set t_ut=                       " Use current background color
set t_Co=256                    " Number of colors
syntax on                       " Enable syntax highlighting
colorscheme lucius              " Select colorscheme
LuciusBlack                     " Select colorscheme configuration

set hlsearch                    " Highlight search queries
set ignorecase                  " Enable case-insensitive search
set incsearch                   " Find search query as it is typed

set cmdheight=1                 " Set height of command window
set showcmd                     " Shows current command being typed

set noeb vb t_vb=               " Disables all error bells/flashes

set shell=zsh                   " Sets the shell

" Indentation settings
set autoindent    " Copy indentation from previous line
set smartindent   " Insert an extra indentation

set expandtab     " Use spaces rather than tab
set shiftwidth=4  " Set indentation of '<<', '>>', and '=='
set softtabstop=4 " Replace tab with spaces

" Key remappings
let mapleader=" " " Map the leader key to space

" Allow up/down movement for wrapped lines
noremap <buffer> <silent> j gj
noremap <buffer> <silent> k gk

" Disable highlighting
nnoremap <leader>h :nohl<CR>

" Numbering
set number relativenumber

" Status bar settings
set laststatus=2        " Display status line permanantly
let g:bufferline_echo=0 " Allow buffer_line plugin to work with lightline
