nnoremap <silent> <C-f> :Files<CR>
nnoremap <silent> <C-g> :Rg<CR>

" Files (runs $FZF_DEFAULT_COMMAND if defined)
" List all files respecting .gitignore including hidden, except contents of .git directory.
let $FZF_DEFAULT_COMMAND="rg --hidden -g '!.git/' --files"
