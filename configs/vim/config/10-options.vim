" ==============================================================================
" Editor options
" ==============================================================================

" ------------------------------------------------------------------------------
" Interface
" ------------------------------------------------------------------------------

" Shows the absolute number of the current line.
set number

" Shows the distance from the current line on all other lines.
set relativenumber

" Highlights the line containing the cursor.
set cursorline

" Always reserves the sign column used by errors, warnings and plugins.
" Prevents the text from shifting when a sign appears.
set signcolumn=yes

" ------------------------------------------------------------------------------
" Indentation
" ------------------------------------------------------------------------------

" Inserts spaces when Tab is pressed instead of a literal tab character.
set expandtab

" Displays an existing tab character as two columns.
set tabstop=2

" Uses two spaces for indentation commands such as >>, << and =.
set shiftwidth=2

" Makes Tab and Backspace work in two-space steps in Insert mode.
set softtabstop=2

" ------------------------------------------------------------------------------
" Search
" ------------------------------------------------------------------------------

" Ignores letter case while searching.
set ignorecase

" Makes a search case-sensitive when its pattern contains an uppercase letter.
set smartcase

" Shows matches while the search pattern is being entered.
set incsearch

" Highlights all matches.
set hlsearch

" ------------------------------------------------------------------------------
" Windows
" ------------------------------------------------------------------------------

" Opens horizontal splits below the current window.
set splitbelow

" Opens vertical splits to the right of the current window.
set splitright

" ------------------------------------------------------------------------------
" Navigation
" ------------------------------------------------------------------------------

" Keeps at least five lines visible above and below the cursor when the file
" position allows it.
set scrolloff=5
