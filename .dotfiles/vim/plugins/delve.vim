" Open terminal in a split window.
let g:delve_new_command = "new"

autocmd FileType go nnoremap <F9> :DlvToggleBreakpoint<CR>
