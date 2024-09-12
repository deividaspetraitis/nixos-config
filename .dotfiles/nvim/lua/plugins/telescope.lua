local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local function fzf_multi_select(prompt_bufnr)
	local picker = action_state.get_current_picker(prompt_bufnr)
	local num_selections = #picker:get_multi_selection()

	if num_selections > 1 then
		-- actions.file_edit throws - context of picker seems to change
		--actions.file_edit(prompt_bufnr)
		actions.send_selected_to_qflist(prompt_bufnr)
		actions.open_qflist()
	else
		actions.file_edit(prompt_bufnr)
	end
end

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

	dependencies = {
		"nvim-lua/plenary.nvim"
	},

	config = function()
		local telescope = require("telescope")
		telescope.load_extension("workspaces")
		telescope.setup {
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
			mappings = {
				i = {
					-- close on escape
					["<esc>"] = actions.close,
					["<tab>"] = actions.toggle_selection + actions.move_selection_next,
					["<s-tab>"] = actions.toggle_selection + actions.move_selection_previous,
					["<cr>"] = fzf_multi_select
				},
				n = {
					["<tab>"] = actions.toggle_selection + actions.move_selection_next,
					["<s-tab>"] = actions.toggle_selection + actions.move_selection_previous,
					["<cr>"] = fzf_multi_select
				}
			},
		}

		local builtin = require('telescope.builtin')

		vim.keymap.set('n', '<leader>f', builtin.find_files, {})
		vim.keymap.set('n', '<leader>F', function()
			local current_dir = vim.fn.expand('%:p:h')
			builtin.find_files({
				prompt_title = "Git Files in " .. vim.fn.fnamemodify(current_dir, ":t"),
				cwd = current_dir,
				find_command = { 'git', 'ls-files', '--exclude-standard', '--cached', '--others' },
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
		vim.keymap.set('n', '<leader>h', builtin.help_tags, {})
		vim.keymap.set("n", "<leader>p", ":Telescope workspaces<CR>")
	end
}
