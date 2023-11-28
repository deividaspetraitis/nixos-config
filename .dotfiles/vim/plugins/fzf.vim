nnoremap <silent> <C-f> :Files<CR>
nnoremap <silent> <C-g> :Rg<CR>

" Files (runs $FZF_DEFAULT_COMMAND if defined)
let $FZF_DEFAULT_COMMAND="rg --files"
