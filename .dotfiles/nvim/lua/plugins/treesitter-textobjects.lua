return {
	"nvim-treesitter/nvim-treesitter-textobjects",
	branch = "main",
	init = function()
		-- Disable entire built-in ftplugin mappings to avoid conflicts.
		-- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
		vim.g.no_plugin_maps = true

		-- Or, disable per filetype (add as you like)
		-- vim.g.no_python_maps = true
		-- vim.g.no_ruby_maps = true
		-- vim.g.no_rust_maps = true
		-- vim.g.no_go_maps = true
	end,
	config = function()
		-- configuration
		require("nvim-treesitter-textobjects").setup {
			select = {
				-- Automatically jump forward to textobj, similar to targets.vim
				lookahead = true,
				-- You can choose the select mode (default is charwise 'v')
				--
				-- Can also be a function which gets passed a table with the keys
				-- * query_string: eg '@function.inner'
				-- * method: eg 'v' or 'o'
				-- and should return the mode ('v', 'V', or '<c-v>') or a table
				-- mapping query_strings to modes.
				selection_modes = {
					['@parameter.outer'] = 'v', -- charwise
					['@function.outer'] = 'V', -- linewise
					-- ['@class.outer'] = '<c-v>', -- blockwise
				},
				-- If you set this to `true` (default is `false`) then any textobject is
				-- extended to include preceding or succeeding whitespace. Succeeding
				-- whitespace has priority in order to act similarly to eg the built-in
				-- `ap`.
				--
				-- Can also be a function which gets passed a table with the keys
				-- * query_string: eg '@function.inner'
				-- * selection_mode: eg 'v'
				-- and should return true of false
				include_surrounding_whitespace = false,
			},

			move = {
				set_jumps = true, -- whether to set jumps in the jumplist
			},
		}

		-- Keymaps for text objects
		vim.keymap.set({ "x", "o" }, "a/", function()
			require "nvim-treesitter-textobjects.select".select_textobject("@comment.outer", "textobjects")
		end)
		vim.keymap.set({ "x", "o" }, "i/", function()
			require "nvim-treesitter-textobjects.select".select_textobject("@comment.inner", "textobjects")
		end)

		-- Keymaps for moving to next/previous text objects
		local move = require("nvim-treesitter-textobjects.move")
		local function textobject_move(key, query)
			vim.keymap.set({ "n", "x", "o" }, "]" .. key, function()
				move.goto_next_start(query, "textobjects")
			end)

			vim.keymap.set({ "n", "x", "o" }, "]" .. key:upper(), function()
				move.goto_next_end(query, "textobjects")
			end)

			vim.keymap.set({ "n", "x", "o" }, "[" .. key, function()
				move.goto_previous_start(query, "textobjects")
			end)

			vim.keymap.set({ "n", "x", "o" }, "[" .. key:upper(), function()
				move.goto_previous_end(query, "textobjects")
			end)
		end

		local function textobject_jump(key, query)
			vim.keymap.set({ "n", "x", "o" }, "]" .. key, function()
				move.goto_next_start(query, "textobjects")
			end)

			vim.keymap.set({ "n", "x", "o" }, "[" .. key, function()
				move.goto_previous_start(query, "textobjects")
			end)
		end

		textobject_jump("/", "@comment.outer")

		local objects = {
			m = "@method.outer",
			b = "@block.outer",
			c = "@call.outer",
			i = "@conditional.outer",
			s = "@statement.outer",
			l = "@loop.outer",
			p = "@parameter.outer",
			a = "@argument.outer",
			f = "@function.outer",
			r = "@return_statement.outer",
			t = "@assignment.rhs",
			T = "@assignment.lhs",
		}

		for key, query in pairs(objects) do
			textobject_move(key, query)
		end
	end,
}
