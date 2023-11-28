" Tmux + Vim configuration
function! TmuxMove(direction)
  let wnr = winnr()
  silent! execute 'wincmd ' . a:direction
  " If the winnr is still the same after we moved,
  " it is the last pane and tmux pane is not zoomed in 
  let tmxz =  system('tmux list-panes -F "#F" | grep -q Z')
	if wnr == winnr() && v:shell_error != 0
	  call system('tmux select-pane -' .  tr(a:direction, 'phjkl', 'lLDUR'))
	end
endfunction
