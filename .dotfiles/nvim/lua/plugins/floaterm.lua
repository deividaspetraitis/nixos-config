return {
	"voldikss/vim-floaterm",
	config = function()
		vim.api.nvim_set_keymap('n', '<leader>tc', ':FloatermNew<CR>', { noremap = true, silent = true })
		vim.api.nvim_set_keymap('t', '<C-\\>c', '<C-\\><C-n>:FloatermNew<CR>', { noremap = true, silent = true })

		vim.api.nvim_set_keymap('n', '<leader>tp', ':FloatermPrev<CR>', { noremap = true, silent = true })
		vim.api.nvim_set_keymap('t', '<C-\\>p', '<C-\\><C-n>:FloatermPrev<CR>', { noremap = true, silent = true })

		vim.api.nvim_set_keymap('n', '<leader>tn', ':FloatermNext<CR>', { noremap = true, silent = true })
		vim.api.nvim_set_keymap('t', '<C-\\>n', '<C-\\><C-n>:FloatermNext<CR>', { noremap = true, silent = true })

		vim.api.nvim_set_keymap('n', '<Leader>tt', ':FloatermToggle<CR>', { noremap = true, silent = true })
		vim.api.nvim_set_keymap('t', '<C-\\>t', '<C-\\><C-n>:FloatermToggle<CR>', { noremap = true, silent = true })
	end
}
