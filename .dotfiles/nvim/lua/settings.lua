-- Use Vim settings, rather than Vi settings
vim.opt.compatible = false

-- Flash screen instead of beep sound
vim.opt.visualbell = true

-- Change how vim represents characters on the screen
vim.opt.encoding = "utf-8"

-- Set the encoding of files written
vim.opt.fileencoding = "utf-8"

-- Indent by 2 spaces when hitting tab
vim.opt.softtabstop = 2

-- Indent by 4 spaces when auto-indenting
vim.opt.shiftwidth = 4

-- Show existing tab with 4 spaces width
vim.opt.tabstop = 4

-- Enable spell checking
vim.opt.spell = true

-- Show @@@ in the last line if it is truncated.
vim.opt.display:append("truncate")

vim.opt.tabpagemax = 100

-- Display line numbers
vim.opt.number = true

-- Set relative numbers
vim.opt.relativenumber = true

-- Status line
vim.opt.laststatus = 2
-- vim.opt.statusline = "" -- TODO

-- Mark the line the cursor is currently in
vim.opt.cursorline = true

-- Enable project specific .vimrc
vim.opt.exrc = true

-- Keep a backup copy of a file when overwriting it.
if vim.fn.has("vms") == 1 then
  vim.opt.backup = false
else
  vim.opt.backup = true
  vim.opt.patchmode = ".orig"
  if vim.fn.has("persistent_undo") == 1 then
    -- Maintain undo history between sessions
    vim.opt.undofile = true
  end
end

-- Append working directory to the PATH, so we can use find to search project files recursively.
vim.opt.path:append(vim.fn.getcwd() .. "/**")

-- While typing a search command, show where the pattern, as it was typed so far, matches.
vim.opt.incsearch = true

-- Enable invisible chars.
vim.opt.list = true
vim.opt.listchars = { tab = "▸ ", eol = "¬" }

-- -- Set cursor shapes based on the mode
-- if vim.opt.term == "xterm-256color" or vim.opt.term == "screen-256color" then
--   vim.opt.t_SI = "\\<Esc>[6 q"  -- start insert mode, bar
--   vim.opt.t_EI = "\\<Esc>[2 q"  -- end insert mode, block

--   -- Restore cursor shape resuming back to Vim
--   vim.opt.t_TI = vim.opt.t_TI .. "\\e[2 q"  -- controls what happens when you exit
--   vim.opt.t_TE = vim.opt.t_TE .. "\\e[4 q"  -- controls what happens when you start
-- end

-- Yank to system clipboard
if vim.fn.system('uname -s') == "Darwin\n" then
  -- OSX
  vim.opt.clipboard = "unnamed"
else
  -- Linux
  vim.opt.clipboard = "unnamedplus"
end

-- Tweak escape time from INSERT mode to NORMAL to switch instantly with no delay
vim.opt.ttimeoutlen = 1

-- Briefly move cursor to the matching pair.
vim.opt.showmatch = true

-- Do not start search from the beginning.
vim.opt.wrapscan = false

vim.opt.cpo:remove("<")

-- Enable tree-sitter folding
vim.wo.foldmethod = 'expr'
vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'

-- By default, set fold level start to 1 just to be aware of such functionality and employ it in daily work
vim.opt.foldlevelstart = 1

-- Display a small column to visually indicate folds
vim.opt.foldcolumn = '2'
