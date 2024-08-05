"###########################################################################
" Mappings
"###########################################################################

" operator pending mappings
" TODO: move to go
omap ic :<C-U>normal! T}vt{<CR>
omap af :<C-U>normal! [V]mz[/func<CR>N[%]`z<CR>
 
"This is how it worked before Vim 5.0. 
" Otherwise the "Q" command starts Ex mode, but you will not need it.
map Q gq
inoremap <C-U> <C-G>u<C-U>

" My keyboard does not have <Home>, <End>
" TODO:
inoremap <S-^> <Home>
inoremap <S-$> <End>

" Navigation between splits  ---------------------- {{{
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

nnoremap <silent> <C-h> :call TmuxMove('h')<cr>
nnoremap <silent> <C-j> :call TmuxMove('j')<cr>
nnoremap <silent> <C-k> :call TmuxMove('k')<cr>
noremap <silent> <C-l> :call TmuxMove('l')<cr>
" }}}

" Move visual selection  ---------------------- {{{
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
" }}}

" Quickfix list navigation  ---------------------- {{{
nnoremap ]l :lnext<CR>
nnoremap [l :lprevious<CR>
" }}}

" Leader key mappings  ---------------------- {{{

" File explorer shortcut
nnoremap <leader>m :FloatermNew vifm<CR>

" rgrep based shortcuts
nnoremap <leader>f :Files<CR>
nnoremap <leader>g :Rg<CR>
nnoremap <leader>b :Buffers<CR>

imap <silent><script><expr> <C-L> copilot#Accept("\<CR>")
let g:copilot_no_tab_map = v:true

" Quick write shortcut
nnoremap <Leader>w :w<CR>

" Same as gf but allows to open and edit non-existing file
" If starts with dot?
noremap <localleader>gf :execute "e " .. expand('%:p:h') .. "/" .. expand('<cfile>')<cr> 
" }}}

" Vimrc related mappings  ---------------------- {{{
nnoremap <Leader>ev :vsplit $MYVIMRC<CR>
nnoremap <Leader>sv :source $MYVIMRC <CR>
" }}}

" Surround text object with X mappings  ---------------------- {{{
vnoremap <Leader>' <esc>`<i'<esc>`>la'
vnoremap <Leader>" <esc>`<i"<esc>`>la"
" }}}

" Disable arrow keys  ---------------------- {{{
" Use hlkj instead!
nnoremap <Up> <Nop>
nnoremap <Down> <Nop>
nnoremap <Right> <Nop>
nnoremap <Left> <Nop>
" }}}

" YCM mappings  ---------------------- {{{
" Close as possible to the defaults
nnoremap <silent> ygd :YcmCompleter GoToDeclaration <CR>
nnoremap <silent> ygi :YcmCompleter GoToImplementation <CR>
nnoremap <silent> yf :YcmCompleter FixIt <CR>
nnoremap <silent> yr :YcmCompleter RefactorRename<Space><C-R><C-W>
nnoremap <silent> yd :YcmCompleter GetDoc <CR>
" }}}

" Git mappings  ---------------------- {{{
nnoremap <silent> gs :call ToggleGstatus()<CR>>
nnoremap <silent> gl :Git status<CR>
nnoremap <silent> <localleader>gd :Gdiffsplit<CR>
" }}}

" Floatterm  ---------------------- {{{
nnoremap <silent> <F12> :FloatermToggle<CR>
tnoremap <silent> <F12> <C-\><C-n>:FloatermToggle<CR>
" }}}

" Session management  ---------------------- {{{
" ss for session save
exec 'nnoremap <Leader>ss :mks! ~/.vim/sessions/*.vim<C-D><BS><BS><BS><BS><BS>'
" sr for session restore
exec 'nnoremap <Leader>sr :so ~/.vim/sessions/*.vim<C-D><BS><BS><BS><BS><BS>'
" }}}
