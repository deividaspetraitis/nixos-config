" Vim Go configuration
setlocal tabstop=4 shiftwidth=4 softtabstop=4

" Spelling settings
setlocal spelllang=en_us
setlocal spellfile=~/.vim/spell/en_us.utf-8.add
setlocal spell

" Syntax folding ---------------------- {{{
" Folds are defined by syntax highlighting
setlocal foldmethod=syntax

" By default set fold level start 1 just to be aware such functionality and employ it in daily work
setlocal foldlevelstart=1

" Display a small column to visually indicate folds
setlocal foldcolumn=2
" }}}

" Format
setlocal formatexpr=go#fmt#Format(-1)

" Filter through gofmt
setlocal equalprg=gofmt

" Tags file
setlocal tags+=~/.vim/tags/go

" Match world for matchit plugin
if exists("loaded_matchit")
  let b:match_words =
	  \ '^\<func\>:\<return\>:^},' .
	  \ '\<for\>:\<range\>:\<}\>,' .
	  \ '\(^\s*\)\@<=\<if\>:\<else\ if\|else\>:^}'
endif

" Set tag for current definition under cursor.
function! SetTag()
    call settagstack(
    \ winnr(),
    \ {'items': [{
    \     'bufnr': bufnr(),
    \     'from': [0, line('.'), col('.'), 0],
    \     'matchnr': 1,
    \     'tagname': expand('<cword>')
    \ }]},
    \ 't'
    \ )
endfunction

" TODO: mapping?
" go list -f '{{.Dir}}' -deps ./... | xargs -I{} ctags --append=yes -R "{}"
" go list <concretefile> -f '{{.Dir}}'

" Move around functions
" See: https://github.com/vim/vim/blob/master/runtime/ftplugin/vim.vim
nnoremap <silent><buffer> [[ m':call search('^\s*\(fu\%[nction]\\|def\)\>', "bW")<CR>
vnoremap <silent><buffer> [[ m':<C-U>exe "normal! gv"<Bar>call search('^\s*\(fu\%[nction]\\|def\)\>', "bW")<CR>
nnoremap <silent><buffer> ]] m':call search('^\s*\(fu\%[nction]\\|def\)\>', "W")<CR>
vnoremap <silent><buffer> ]] m':<C-U>exe "normal! gv"<Bar>call search('^\s*\(fu\%[nction]\\|def\)\>', "W")<CR>

" Move around previous/next unmatched "if".
" noremap <silent><buffer> [# :call search('^\s*\<if\>\|\<else if\>|\<else\>', "bW")<CR>
" noremap <silent><buffer> ]# :call search('^\s*\<else\>\|<else if\>', "W")<CR>

" YCM mappings, we want to make it to work close as possible to the defaults
"
" Originally: Jump to the definition of the keyword under the cursor.
nnoremap <silent><buffer> <C-]> <cmd>call SetTag()<cr><cmd>YcmCompleter GoToDefinition<cr>
" Originally: Like CTRL-], but use ":tselect" instead of ":tag"
nnoremap <silent><buffer> g] :YcmCompleter GoToReferences <CR>
nnoremap <silent><buffer> <localleader>gD :YcmCompleter GoToDeclaration <CR>
nnoremap <silent><buffer> <localleader>gi :YcmCompleter GoToImplementation <CR>
nnoremap <silent><buffer> <localleader>f :YcmCompleter FixIt <CR>
nnoremap <buffer> <localleader>r :YcmCompleter RefactorRename<Space><C-R><C-W>
nnoremap <silent><buffer> <C-w>} :YcmCompleter GetDoc <CR>

" Auto generate tags file on file write of *.go
augroup tags_generate
	autocmd!
	" Go list will list full path to packages of current file, -e flag instructs to ignore encountered errors.
	" Generated list is passed to ctags utility to generate tags for given packages, append flag instructs to append instead of full-rewrite of tags file.
	" Because command might take some time to finish it it executed in background to avoid blocking.
	" TODO: if one process is already in progress we should not to run another one, otherwise both processes ends up writing to the same file and corrupting it?
	" autocmd BufWritePost *.go silent! execute "!go list -e -f '{{.Dir}}' -deps " .. shellescape(expand('%:p')) .. " | xargs -I{} ctags --append=yes -R '{}' &"
	autocmd BufWritePost *.go silent! :call GoCtags(expand('%:p'))
augroup END

function! GoCtags(file)
  " execute "!go list -e -f '{{.Dir}}' -deps " .. shellescape(a:file) .. " | xargs -I{} ctags --quiet=yes --append=yes -R '{}' &"
  execute "!ctags -R . 2>/dev/null &"
endfunction
