return {
	{
		"Joakker/lua-json5",
		build = "./install.sh"
	},
	{
		"mfussenegger/nvim-dap",
		tag = "0.8.0",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"nvim-telescope/telescope-dap.nvim",
			"theHamsta/nvim-dap-virtual-text",
			"leoluz/nvim-dap-go",
		},
		config = function()
			local dap, dapui = require("dap"), require("dapui")

			dapui.setup({})

			-- Load the dap extension for telescope
			require('telescope').load_extension('dap')
			require('dap-go').setup({
				-- options related to running closest test
				tests = {
					-- enables verbosity when running the test.
					verbose = true,
				},
			})
			-- TODO:
			-- require('dap.ext.vscode').json_decode = require 'json5'.parse
			require('dap.ext.vscode').load_launchjs(nil, {})

			-- Enable virtual text
			require("nvim-dap-virtual-text").setup({
				enabled = true,
				enable_commands = true,
				highlight_changed_variables = true,
				highlight_new_as_changed = false,
				show_stop_reason = true,
				commented = false,
				only_first_definition = true,
				all_references = false,
				filter_references_pattern = '<module',
				virt_text_pos = 'eol',
				all_frames = false,
				virt_lines = false,
				virt_text_win_col = nil
			})

			-- Set up the UI
			-- dap.listeners.after.event_initialized["dapui_config"] = function()
			-- 	dapui.open()
			-- end
			-- dap.listeners.before.event_terminated["dapui_config"] = function()
			-- 	dapui.close()
			-- end
			-- dap.listeners.before.event_exited["dapui_config"] = function()
			-- 	dapui.close()
			-- end

			-- Set up the keybindings
			-- help dap.txt
			vim.keymap.set('n', '<leader>d~', function() dapui.toggle() end)
			vim.keymap.set('n', '<leader>dd', function() dap.disconnect() end)
			vim.keymap.set('n', '<leader>dr', function() dap.restart() end)
			vim.keymap.set('n', '<leader>dx', function() dap.repl.open() end)
			vim.keymap.set('n', '<leader>dt', function() require('dap-go').debug_test() end)
			vim.keymap.set('n', '<leader>dl', function() require('dap-go').debug_last_test() end)
			vim.keymap.set('n', '<leader>dc', function() dap.continue() end)
			vim.keymap.set('n', '<leader>dp', function() dap.pause() end)
			vim.keymap.set('n', '<leader>db', function() dap.toggle_breakpoint() end)
			vim.keymap.set('n', '<leader>dn', function() dap.step_over() end)
			vim.keymap.set('n', '<leader>do', function() dap.step_out() end)
			vim.keymap.set('n', '<leader>di', function() dap.step_into() end)

			-- Set up the signs for the debugger
			vim.fn.sign_define("DapStopped", { text = vim.g.vinux_diagnostics_signs_warning, texthl = "DiagnosticWarn" })
			vim.fn.sign_define("DapBreakpoint", { text = vim.g.vinux_diagnostics_signs_info, texthl = "DiagnosticInfo" })
			vim.fn.sign_define("DapBreakpointRejected",
				{ text = vim.g.vinux_diagnostics_signs_error, texthl = "DiagnosticError" })
			vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DiagnosticInfo" })
			vim.fn.sign_define("DapLogPoint", { text = ".>", texthl = "DiagnosticInfo" })
		end
	},
}
