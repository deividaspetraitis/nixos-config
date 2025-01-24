function vim.getVisualSelection()
	vim.cmd('noau normal! "vy"')
	local text = vim.fn.getreg('v')
	vim.fn.setreg('v', {})

	text = string.gsub(text, "\n", "")
	if #text > 0 then
		return text
	else
		return ''
	end
end

return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" }
	},

	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")

		telescope.load_extension("workspaces")
		telescope.load_extension("fzf")
		telescope.setup {
			extensions = {
				fzf = {
					fuzzy = true,    -- false will only do exact matching
					override_generic_sorter = true, -- override the generic sorter
					override_file_sorter = true, -- override the file sorter
					case_mode = "smart_case", -- or "ignore_case" or "respect_case"
					-- the default case_mode is "smart_case"
				}
			},
			pickers = {
				find_files = {
					hidden = true,
					file_ignore_patterns = { "%.git/" } -- Ignore .git directory
				},
				grep_string = {
					additional_args = { "--hidden", "--glob", "!.git/**", "--fixed-strings", "--ignore-case" }
				},
				live_grep = {
					additional_args = { "--hidden", "--glob", "!.git/**", "--fixed-strings", "--ignore-case" }
				},
				buffers = {
					mappings = {
						i = {
							["<c-d>"] = actions.delete_buffer + actions.move_to_top,
						}
					}
				},
				lsp_document_symbols = {
					symbol_width = 80
				}
			},
		}

		local builtin = require('telescope.builtin')

		vim.keymap.set('n', '<leader>f', builtin.find_files, {})
		vim.keymap.set('n', '<leader>F', function()
			local current_dir = vim.fn.expand('%:p:h')
			builtin.find_files({
				prompt_title = "Files in " .. vim.fn.fnamemodify(current_dir, ":t"),
				cwd = current_dir,
			})
		end, {})
		vim.keymap.set('n', '<leader>g', builtin.live_grep, {})
		vim.keymap.set('v', '<space>g', function()
			local text = vim.getVisualSelection()
			builtin.grep_string({ default_text = text })
		end, {})
		vim.keymap.set('n', '<leader>wg', function()
			local word = vim.fn.expand("<cword>")
			builtin.grep_string({ search = word })
		end)
		vim.keymap.set('n', '<leader>r', builtin.lsp_references, {})
		vim.keymap.set('n', '<leader>s', builtin.lsp_document_symbols, {})
		vim.keymap.set('n', '<leader>b', builtin.buffers, {})
		vim.keymap.set('n', '<leader>m', builtin.marks, {})
		vim.keymap.set('n', '<leader>h', builtin.help_tags, {})
		vim.keymap.set("n", "<leader>p", ":Telescope workspaces<CR>")
	end
}
