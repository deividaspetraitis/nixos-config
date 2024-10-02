-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- The original meaning of Ctrl-j is 'move [n] lines downward'
-- Turn off it.
vim.g.C_Ctrl_j = 'off'
vim.g.C_Ctrl_k = 'off'

-- Move visual selection
vim.api.nvim_set_keymap('v', 'J', ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', 'K', ":m '<-2<CR>gv=gv", { noremap = true, silent = true })

-- Quickfix list navigation
vim.api.nvim_set_keymap('n', ']l', ':lnext<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '[l', ':lprevious<CR>', { noremap = true, silent = true })

-- Quick write shortcut
vim.api.nvim_set_keymap('n', '<localleader>w', ':w<CR>', { noremap = true, silent = true })
--
-- Remap <C-w> navigation keys in terminal mode
vim.api.nvim_set_keymap('t', '<C-w>h', '<C-\\><C-n><C-w>h', { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<C-w>j', '<C-\\><C-n><C-w>j', { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<C-w>k', '<C-\\><C-n><C-w>k', { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<C-w>l', '<C-\\><C-n><C-w>l', { noremap = true, silent = true })
