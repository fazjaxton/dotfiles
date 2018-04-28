" No vi compatibility
set nocompatible

" Allow switching buffers without saving
set hidden


" Use highlighting
syntax on

" Use filetype plugins
filetype plugin on

" Key mappings
noremap <C-s> :set invhls<CR>
noremap <C-c> ct_

let mapleader=","

" Case-insensitive if search is all lowercase
set ignorecase
set smartcase

" Search while typing, highlight searches
set incsearch
set hls

" Tab completion for files
set wildmode=longest:full
set wildmenu

" Show commands in status line while typing
set showcmd

" Use the mouse in non-gui vim
set mouse=a

" Allow backspace to remove anything, including characters not inserted
" in this session
set backspace=indent,eol,start

" Show status bar with ruler
set laststatus=2
set ruler

" Don't delay for ESC-led key sequences, and use a long timeout for <leader>
set timeout
set timeoutlen=4000
set ttimeout
set ttimeoutlen=25

" In text-wrap mode make navigation keys move one visible (wrapped) line,
" not jump over the complete line.  Use 'unset j/k' to undo this.
noremap j gj
noremap k gk

" Make 'Ctrl-k' and friends change windows instead of 'Ctrl-w k'
noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l
" Same while in insert mode
inoremap <C-h> <C-o><C-w>h
inoremap <C-j> <C-o><C-w>j
inoremap <C-k> <C-o><C-w>k
inoremap <C-l> <C-o><C-w>l

" Type buffer number, then <leader>-g to jump to that buffer number
noremap <leader>g <C-^>

" Change CTRL-] to show a list of tags if there are multiple matches instead
" of using the first one.  (Still jumps immediately if only one match).
noremap <C-]> g<C-]>
noremap <C-w><C-]> :stj <C-r><C-w><CR>

" Set pop-up menu colors
highlight Pmenu    guibg=green4         guifg=black
highlight Pmenusel guibg=DarkGreen      guifg=snow3
highlight Pmenu    ctermfg=LightGray    ctermbg=DarkBlue
highlight Pmenusel ctermfg=White        ctermbg=DarkRed

" Fold options
set foldlevel=10
set foldmethod=manual
highlight Folded guibg=DodgerBlue4 guifg=gray

" Custom highlighting
" see ~/.vim/after/syntax

" Move through items/errors in quickfix window
noremap <C-n> :cn<cr>
noremap <C-p> :cp<cr>
noremap <C-q> :cclose<cr>

" Don't automap toggle lists
let g:toggle_list_no_mappings=1
" quickfix window is full width
let g:toggle_list_copen_command="botright copen"

let g:ycm_key_list_select_completion=['<Down>']

call plug#begin()

Plug 'rking/ag.vim'
Plug 'tpope/vim-fugitive'
Plug 'christoomey/vim-tmux-navigator'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' }
Plug 'junegunn/fzf.vim'
Plug 'milkypostman/vim-togglelist'
Plug 'Valloric/YouCompleteMe'
Plug 'lyuts/vim-rtags'
Plug 'mbbill/undotree'

call plug#end()

" FZF bindings
noremap <leader>fo :Files<CR>
noremap <leader>fe :Buffers<CR>
noremap <leader>ft :Tags<CR>

" togglelist bindings
noremap <leader>q :botright call ToggleQuickfixList()<CR>

" Undotree bindings
noremap <leader>u :UndotreeToggle<cr>

" "Zoom" in on the current file by making a full-window-sized tab for it
noremap <leader>z :tab split<CR>
" (Can also just C-w c to close tab)
noremap <leader>Z :tabclose<CR>

" Delete the current buffer without closing window
noremap <leader>bd :bp \| bd # <CR>

" Set <leader>v to preview the tag under cursor
noremap <leader>v :ptag <C-R><C-W><CR>
noremap <leader>c :pclose<CR>

" Ctrl-A/X inc/dec letters and numbers
set nrformats=bin,hex,alpha

" Set preview height for small tag preview window
set previewheight=5

" Function to jump from header to source and back
function! HeaderSourceSwap()
    let s:ext = expand("%:e")
    let s:root = expand("%:r")
    let s:newext = s:ext
    if s:ext =~ "c"
        if filereadable(s:root . ".h")
            let s:newext = "h"
        endif
    elseif s:ext =~ "cpp"
        if filereadable(s:root . ".hpp")
            let s:newext = "hpp"
        elseif filereadable(s:root . ".h")
            let s:newext = "h"
        endif
    elseif s:ext =~ "h"
        if filereadable(s:root . ".c")
            let s:newext = "c"
        elseif filereadable(s:root . ".cpp")
            let s:newext = "cpp"
        endif
    elseif s:ext =~ "hpp"
        if filereadable(s:root . ".cpp")
            let s:newext = "cpp"
        elseif filereadable(s:root . ".c")
            let s:newext = "c"
        endif
    endif
    exec "e " . s:root . "." . s:newext
    unlet s:ext
    unlet s:newext
    unlet s:root
endfunction

" Function to jump from header to inline header and back
function! HeaderInlineSwap()
    let s:ext = expand("%:e")
    let s:root = expand("%:r")
    let s:newfile = expand("%:f")
    let s:idx = strridx(s:root, "_inline")
    if s:idx == -1
        if filereadable(s:root . "_inline.h")
            let s:newfile = s:root . "_inline.h"
        endif
    elseif s:idx == strlen(s:root) - strlen("_inline")
        let s:newroot = strpart(s:root,0,s:idx)
        if filereadable(s:newroot . ".h")
            let s:newfile = s:newroot . ".h"
        endif
        unlet s:newroot
    endif
        
    exec "e " s:newfile
    unlet s:ext
    unlet s:root
    unlet s:newfile
endfunction

noremap <leader>h :call HeaderSourceSwap()<CR>
noremap <leader>i :call HeaderInlineSwap()<CR>

noremap <F6> :!ctags -R<CR><CR>

set scrolloff=5

""""""""""""""""""""""""
" Use with :Usespaces <num> and we
" are configured with indentation of <num>
" using spaces.
com! -nargs=1 Usespaces
            \ set tabstop=<args> |
            \ set expandtab |
            \ set shiftwidth=<args> |
            \ set softtabstop=<args> |
            \ set nocopyindent

""""""""""""""""""""""""
" Use with :Usetabs <num> and we are
" configured with indentation of <num> using
" tabs.
com! -nargs=1 Usetabs
            \ set tabstop=<args> |
            \ set noexpandtab |
            \ set shiftwidth=<args> |
            \ set softtabstop=<args> |
            \ set copyindent

""""""""""""""""""""""""
" GNU indentation style is a mess
com! -nargs=0 Gnuindent
            \ set tabstop=8 |
            \ set shiftwidth=2 |
            \ set softtabstop=2 |
            \ set noexpandtab |
            \ set nocopyindent

set background=dark
colorscheme molokai

" Run a local configuration script if one exists
ru local.vim

