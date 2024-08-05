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

" Toggle Git summary window.
" Source: https://vi.stackexchange.com/questions/39086/how-to-toggle-fugitive-status-window
function! ToggleGstatus() abort
  for l:winnr in range(1, winnr('$'))
    if !empty(getwinvar(l:winnr, 'fugitive_status'))
      exe l:winnr 'close'
      return
    endif
  endfor
  keepalt Git
endfunction
