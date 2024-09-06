return {
	"nvim-telescope/telescope.nvim",

	dependencies = {
		"nvim-lua/plenary.nvim"
	},

	config = function()
		require('telescope').setup {
			pickers = {
				find_files = {
					hidden = true
				},
				grep_string = {
					additional_args = { "--hidden" }
				},
				live_grep = {
					additional_args = { "--hidden" }
				},
			},
		}

		local builtin = require('telescope.builtin')

		vim.keymap.set('n', '<leader>f', builtin.find_files, {})
		vim.keymap.set('n', '<C-p>', function()
			local current_dir = vim.fn.expand('%:p:h')
			builtin.find_files({
				prompt_title = "Git Files in " .. vim.fn.fnamemodify(current_dir, ":t"),
				cwd = current_dir,
				find_command = { 'git', 'ls-files', '--exclude-standard', '--cached', '--others' },
			})
		end, {})
		vim.keymap.set('n', '<leader>g', builtin.live_grep, {})
		vim.keymap.set('n', '<leader>r', builtin.lsp_references, {})
		vim.keymap.set('n', '<leader>s', builtin.lsp_document_symbols, {})
		vim.keymap.set('n', '<leader>b', builtin.buffers, {})
		vim.keymap.set('n', '<leader>h', builtin.help_tags, {})
	end
}
