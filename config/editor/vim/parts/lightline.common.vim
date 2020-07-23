" Configure 'lightline'
let g:lightline = {
\   'colorscheme': 'wombat',
\
\   'active': {
\     'left':  [['mode'], ['readonly'], ['bufferline']],
\     'right': [['linter_errors', 'linter_warnings', 'linter_ok', 'lineinfo'], ['percent']]
\   },
\
\   'component_function': {
\     'readonly':   'LightLineReadonly',
\     'bufferline': 'LightLineBufferLine'
\   },
\
\   'component_visible_condition': {
\     'readonly': '(&filetype!="help"&& &readonly)',
\   },
\
\   'component_expand': {
\     'linter_warnings': 'lightline#ale#warnings',
\     'linter_errors': 'lightline#ale#errors',
\     'linter_ok': 'lightline#ale#ok',
\   },
\
\   'component_type': {
\     'linter_warnings': 'warning',
\     'linter_errors': 'error',
\     'linter_ok': 'left',
\   },
\
\   'separator': { 'left': '', 'right': '' },
\   'subseparator': { 'left': '|', 'right': '|' }
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
