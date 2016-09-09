"---------"
" Vundle  "
"---------"
set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Required (has to be first)
Plugin 'gmarik/Vundle.vim'

" Colorschemes
Plugin 'flazz/vim-colorschemes'

" Completion
Plugin 'valloric/youcompleteme'

" Navigation
Plugin 'christoomey/vim-tmux-navigator'

" Status bar
Plugin 'itchyny/lightline.vim'
Plugin 'bling/vim-bufferline'

" Syntax coloring
Plugin 'justinmk/vim-syntax-extra'        " C
Plugin 'octol/vim-cpp-enhanced-highlight' " C++
Plugin 'fatih/vim-go'                     " Golang
Plugin 'potatoesmaster/i3-vim-syntax'     " i3 configuration
Plugin 'hdima/python-syntax'              " Python

" Syntax errors
Plugin 'scrooloose/syntastic'

call vundle#end()
filetype plugin indent on

"--------"
" Editor "
"--------"
set number        " Display line numbers
set numberwidth=3 " Width of number column

set textwidth=80  " Width of the text
set fo+=t

set t_ut=         " Use current background color
set t_Co=256      " Number of colors
syntax on
colorscheme lucius
LuciusBlack

"-------------"
" Indentation "
"-------------"
set autoindent    " Copy indentation from previous line
set smartindent   " Insert an extra indentation

set expandtab     " Use spaces rather than tab
set shiftwidth=4  " Set indentation of '<<', '>>', and '=='
set softtabstop=4 " Replace tab with spaces

"------------"
" Status Bar "
"------------"
set laststatus=2
let g:bufferline_echo=0

let g:lightline = {
  \ 'colorscheme': 'wombat',
  \
  \ 'active': {
  \   'left':  [['mode'], ['readonly'], ['bufferline']],
  \   'right': [['syntastic', 'lineinfo'], ['percent']]
  \ },
  \
  \ 'component_function': {
  \   'readonly':   'LightLineReadonly',
  \   'bufferline': 'LightLineBufferLine'
  \ },
  \
  \ 'component_visible_condition': {
  \   'readonly': '(&filetype!="help"&& &readonly)',
  \ },
  \
  \ 'component_expand': {
  \   'syntastic': 'SyntasticStatuslineFlag',
  \ },
  \
  \ 'component_type': {
  \   'syntastic': 'error',
  \ },
  \
  \ 'separator': { 'left': '', 'right': '' },
  \ 'subseparator': { 'left': '|', 'right': '|' }
  \ }

function! LightLineReadonly()
    if &filetype == "help"
        return ""
    elseif &readonly
        return "RO"
    else
        return ""
    endif
endfunction

function! LightLineModified()
    if &filetype == "help"
        return ""
    elseif &modified
        return "+"
    elseif &modifiable
        return ""
    else
        return "-"
    endif
endfunction

function! LightLineBufferLine()
    let st=g:bufferline#refresh_status()
    return g:bufferline_status_info.before . g:bufferline_status_info.current . g:bufferline_status_info.after
endfunction

augroup AutoSyntastic
  autocmd!
  autocmd BufWritePost *.c,*.cpp,*.py,*.go call s:syntastic()
augroup END
function! s:syntastic()
  SyntasticCheck
  call lightline#update()
endfunction

"------------"
" Completion "
"------------"
let g:ycm_show_diagnostics_ui = 0 " Enable Syntantic to work
let g:ycm_global_ycm_extra_conf='/home/potok/.vim/bundle/youcompleteme/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py'

"------------"
" Correction "
"------------"
let g:syntastic_check_on_open = 1
