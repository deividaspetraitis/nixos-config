" Vim compiler file

if exists("current_compiler")
  finish
endif
let current_compiler = "golangci-lint"

let s:cpo_save = &cpo
set cpo-=C

setlocal makeprg=golangci-lint\ run
setlocal errorformat="%f:%l:%c:\ %m,%f:%l:%c\ %#%m"

let &cpo = s:cpo_save
unlet s:cpo_save
