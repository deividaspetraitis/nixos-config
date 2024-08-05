setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4

" Originally: Jump to the definition of the keyword under the cursor.
nnoremap <silent> <C-]> <cmd>call SetTag()<cr><cmd>YcmCompleter GoToDefinition<cr>

" Originally: Like CTRL-], but use ":tselect" instead of ":tag"
nnoremap <silent> g] :YcmCompleter GoToReferences <CR>
