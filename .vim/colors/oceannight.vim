" Inspiration: "OceanBlack" theme by Chris Vertonghen

set background=dark

highlight clear
if exists("syntax_on")
    syntax reset
endif

let g:colors_name = "oceannight"

highlight Normal         cterm=none           ctermfg=252 ctermbg=0
highlight NonText        cterm=none           ctermfg=117 ctermbg=0

highlight Visual         cterm=reverse        ctermfg=72  ctermbg=15
highlight VisualNOS      cterm=bold,underline ctermfg=151 ctermbg=0

highlight Cursor         cterm=none           ctermfg=15  ctermbg=152
highlight CursorIM       cterm=bold           ctermfg=15  ctermbg=152
"highlight CursorColumn
"highlight CursorLine

highlight Directory      ctermfg=12            ctermbg=0

highlight DiffAdd        cterm=none           ctermfg=15  ctermbg=22
highlight DiffChange     cterm=none           ctermfg=207 ctermbg=90
highlight DiffDelete     cterm=none           ctermfg=19  ctermbg=17
highlight DiffText       cterm=bold           ctermfg=226 ctermbg=90

highlight Question       cterm=bold           ctermfg=85  ctermbg=0
highlight ErrorMsg       ctermfg=230          ctermbg=167
highlight ModeMsg        ctermfg=77           ctermbg=22
highlight MoreMsg        cterm=bold           ctermfg=72  ctermbg=0
highlight WarningMsg     cterm=bold           ctermfg=203 ctermbg=0

highlight LineNr         ctermfg=6          ctermbg=233
highlight Folded         cterm=none           ctermfg=152 ctermbg=66
highlight FoldColumn     cterm=none           ctermfg=152 ctermbg=66
"highlight SignColumn

highlight Search         cterm=none           ctermfg=16  ctermbg=66
highlight IncSearch      cterm=reverse        ctermfg=151 ctermbg=0
"highlight MatchParen

"highlight PMenu
"highlight PMenuSBar
"highlight PMenuSel
"highlight PMenuThumb

highlight SpecialKey     ctermfg=60           ctermbg=0

"highlight SpellBad
"highlight SpellCap
"highlight SpellLocal
"highlight SpellRare

highlight StatusLine     cterm=none           ctermfg=0   ctermbg=254
highlight StatusLineNC   cterm=none           ctermfg=234 ctermbg=247
highlight VertSplit      cterm=none           ctermfg=0   ctermbg=247

highlight WildMenu       cterm=bold           ctermfg=0   ctermbg=118

"highlight TabLine
"highlight TabLineFill
"highlight TabLineSel

highlight Title          cterm=bold           ctermfg=171 ctermbg=0

"highlight Menu
"highlight Scrollbar
"highlight Tooltip

"          Syntax         Groups
highlight Comment        cterm=none           ctermfg=60

highlight Constant       cterm=none           ctermfg=78   ctermbg=0
highlight String         cterm=none           ctermfg=78 ctermbg=0
highlight Character      cterm=none           ctermfg=78 ctermbg=0
highlight Number         cterm=none           ctermfg=78  ctermbg=0
highlight Boolean        cterm=none           ctermfg=78  ctermbg=0
highlight Number         cterm=none           ctermfg=78  ctermbg=0

highlight Identifier     cterm=none           ctermfg=111 ctermbg=0
highlight Function       cterm=none           ctermfg=111 ctermbg=0

highlight Statement      cterm=none           ctermfg=35
highlight Conditional    cterm=none           ctermfg=35  ctermbg=0
highlight Repeat         cterm=none           ctermfg=35  ctermbg=0
highlight Label          cterm=none           ctermfg=35  ctermbg=0
highlight Operator       cterm=none           ctermfg=252 ctermbg=0
highlight Keyword        cterm=none           ctermfg=35  ctermbg=0
highlight Exception      cterm=none           ctermfg=35  ctermbg=0

highlight PreProc        ctermfg=78
highlight Include        cterm=none           ctermfg=152 ctermbg=0
highlight Define         cterm=none           ctermfg=152 ctermbg=0
highlight Macro          cterm=none           ctermfg=152 ctermbg=0
highlight PreCondit      cterm=none           ctermfg=74  ctermbg=0

highlight Type           cterm=none           ctermfg=33
highlight StorageClass   cterm=none           ctermfg=33 ctermbg=0
highlight Structure      cterm=none           ctermfg=33 ctermbg=0
highlight Typedef        cterm=none           ctermfg=33 ctermbg=0

highlight Special        ctermfg=247
"highlight SpecialChar
"highlight Tag
"highlight Delimiter
"highlight SpecialComment
"highlight Debug

highlight Underlined     cterm=underline      ctermfg=102 ctermbg=0

highlight Ignore         ctermfg=67

highlight Error          ctermfg=230          ctermbg=167

highlight Todo           ctermfg=51           ctermbg=66
