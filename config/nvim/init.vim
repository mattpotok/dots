" Neovim configuration file.

" Install vim-plug
if ! filereadable(expand('~/.config/nvim/autoload/plug.vim'))
    echo "Downloading junegunn/vim-plug to manage plugins..."
    silent !mkdir -p ~/.config/nvim/autoload/
    silent !curl "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" > ~/.config/nvim/autoload/plug.vim
endif


" Plugins
call plug#begin('~/.config/nvim/plugged')

    " Buffers
    Plug 'bling/vim-bufferline'
    Plug 'moll/vim-bbye'

    " Colorschemes
    Plug 'jonathanfilip/vim-lucius'

    " Linting (and completion)
    Plug 'ervandew/supertab'
    Plug 'w0rp/ale'

    " Navigation
    Plug 'christoomey/vim-tmux-navigator'

    " Status bar
    Plug 'itchyny/lightline.vim'
    Plug 'maximbaz/lightline-ale'

    " Syntax
    Plug 'cespare/vim-toml'                     " TOML
    Plug 'mboughaba/i3config.vim'               " i3
    Plug 'octol/vim-cpp-enhanced-highlight'     " C++
    Plug 'pangloss/vim-javascript'              " Javascript
    Plug 'plasticboy/vim-markdown'              " Markdown
    Plug 'rust-lang/rust.vim'                   " Rust


call plug#end()


" Ale plugin
    let g:ale_lint_on_text_changed = 'never'  " Lint only on file open/save
    let g:ale_completion_enabled = 1

    let g:ale_linters = {
    \   'c': ['clangd'],
    \   'cpp': ['clangd'],
    \   'python': ['pyls'],
    \   'rust': ['rls'],
    \}

    let g:ale_python_pyls_config =  { 'pyls': { 'plugins': { 'pydocstyle': { 'enabled': v:true } } }, }  " NOTE may need to set to v:false
    
" Bufferline plugin
    "let g:bufferline_rotate = 1


" Supertab plugin
    set completeopt=menu,menuone,preview,noselect,noinsert
    let g:SuperTabDefaultCompletionType = "<c-n>"


" Editor settings
    set formatoptions-=cro  " Disable automatic comment insertion  " FIXME
    set fo+=t               " Auto-wrap text using textwidth
    set number              " Display line numbers
    set numberwidth=3       " Width of number column
    set splitbelow          " Split (vertical)  new files below
    set splitright          " Split (horizontal) new files right
    set textwidth=80        " Width of the text

    set t_ut=               " Use current background color
    set t_Co=256            " Number of colors
    syntax on               " Enable syntax highlighting
    colorscheme lucius      " Select colorscheme
    LuciusBlack             " Select colorscheme configuration

    set hlsearch            " Highlight search queries
    set ignorecase          " Enable case-insensitive search
    set incsearch           " Find search query as it is typed

    set cmdheight=1         " Set height of command window
    set showcmd             " Shows current command being typed

    set noeb vb t_vb=       " Disables all error bells/flashes

    set shell=zsh           " Sets the shell


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

    augroup numbertoggle
        autocmd!
        autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu | set rnu   | endif
        autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu | set nornu | endif
    augroup END


" Status bar
    set laststatus=2        " Display status line permanantly
    let g:bufferline_echo=0 " Allow buffer_line plugin to work with lightline

    " Configure status bar
    let g:lightline = {
        \ 'colorscheme': 'wombat',
        \
        \ 'active': {
        \   'left':  [['mode'], ['readonly'], ['bufferline']],
        \   'right': [['linter_errors', 'linter_warnings', 'linter_ok', 'lineinfo'], ['percent']]
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
        \   'linter_warnings': 'lightline#ale#warnings',
        \   'linter_errors': 'lightline#ale#errors',
        \   'linter_ok': 'lightline#ale#ok',
        \ },
        \
        \ 'component_type': {
        \   'linter_warnings': 'warning',
        \   'linter_errors': 'error',
        \   'linter_ok': 'left',
        \ },
        \
        \ 'separator': { 'left': '', 'right': '' },
        \ 'subseparator': { 'left': '|', 'right': '|' }
        \ }

    " Display read-only status indicator
    function! LightLineReadonly()
        if &filetype == "help"
            return ""
        elseif &readonly
            return "RO"
        else
            return ""
        endif
    endfunction

    " Display buffer_line plugin information
    function! LightLineBufferLine()
        call g:bufferline#refresh_status()
        let b = g:bufferline_status_info.before
        let c = g:bufferline_status_info.current
        let a = g:bufferline_status_info.after
        return b . c . a
    endfunction
