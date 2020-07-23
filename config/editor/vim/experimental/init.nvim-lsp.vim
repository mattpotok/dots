" Plugins
call plug#begin('~/.config/nvim/plugged')
    Plug 'neovim/nvim-lsp'
    Plug 'ervandew/supertab'
call plug#end()

lua << EOF
    local nvim_lsp = require'nvim_lsp'
    nvim_lsp.pyls.setup{
        settings = {
            pyls = {
                plugins = {
	           pydocstyle = {
	               enabled = true;
	           },
		   pyls_mypy = {
		       enabled = true;
		   }
	        }
	   }
        }
    }
EOF

" Supertab plugin
    set completeopt=menu,menuone,preview,noselect,noinsert
    let g:SuperTabDefaultCompletionType = "<c-n>"
    let g:SuperTabClosePreviewOnPopupClose = 1

set omnifunc=lsp#omnifunc
