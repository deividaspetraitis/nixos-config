" Files (runs $FZF_DEFAULT_COMMAND if defined)
" List all files respecting .gitignore including hidden, except contents of .git directory.
let $FZF_DEFAULT_COMMAND="rg --hidden -g '!.git/' --files"

" Bindings for preview window scroll
let $FZF_DEFAULT_OPTS="--preview-window 'right:57%' --preview 'bat --theme=OneHalfLight (light --style=numbers --line-range :300 {}'
\ --bind ctrl-y:preview-up,ctrl-e:preview-down,
\ctrl-b:preview-page-up,ctrl-f:preview-page-down,
\ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down"

# Set bat theme
let $BAT_THEME = 'gruvbox-light'
