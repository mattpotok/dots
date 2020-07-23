" General settings
let g:ale_completion_enabled = 1
let g:ale_lint_on_text_changed = 'never'  " Lint only on file open/save
let g:ale_fix_on_save = 1                 " Fix on file save

" Fixers
let g:ale_fixers = {
\   'javascript': ['eslint'],
\   'typescript': ['eslint'],
\ }

" Linters
let g:ale_linters = {
\   'c': ['clangd'],
\   'cpp': ['clangd', 'cpplint'],
\   'javascript': ['eslint', 'tsserver'],
\   'python': ['mypy', 'pyls'],
\   'rust': ['analyzer'],
\   'typescript': ['eslint', 'tsserver'],
\ }

" C/C++
let g:ale_c_parse_compile_commands = 1

" Python
let g:ale_python_pyls_config =  { 
\   'pyls': {
\     'plugins': {
\       'pydocstyle': { 'enabled': v:true },
\       'pylint': { 'enabled': v:true, 'args': ['--extension-pkg-whitelist=cv2'] }
\     }
\   },
\ }

" Rust
let g:rustfmt_autosave = 1
