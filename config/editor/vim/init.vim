" Neovim configuration file

" Install vim-plug
if ! filereadable(expand('~/.config/nvim/autoload/plug.vim'))
    echo "Downloading junegunn/vim-plug to manage plugins..."
    silent !mkdir -p ~/.config/nvim/autoload/
    silent !curl "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" > ~/.config/nvim/autoload/plug.vim
endif

" Plugins
call plug#begin('~/.config/nvim/plugged')
    source ~/.config/nvim/parts/plugins.common.vim
call plug#end()

" Ale plugin
source ~/.config/nvim/parts/ale.common.vim
    
" Supertab plugin
source ~/.config/nvim/parts/supertab.common.vim

" General settings
source ~/.config/nvim/parts/settings.common.vim

" Status bar
source ~/.config/nvim/parts/lightline.common.vim

" Language specific
source ~/.config/nvim/parts/languages.common.vim
