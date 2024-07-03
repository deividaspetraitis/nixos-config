" Fix gopls not found
let g:ycm_gopls_binary_path = "/run/current-system/sw/bin/gopls"
let g:ycm_show_diagnostics_ui = 1
let g:ycm_enable_semantic_highlighting = 0

" Turning off, disables highlighting and resolved visual selection issue on error
let g:ycm_enable_diagnostic_highlighting = 1
let g:ycm_enable_diagnostic_signs = 0

" Populate location list with new diagnostic data.
" This is useful for navigating between errors.
" See :help location-list
let g:ycm_always_populate_location_list = 1
