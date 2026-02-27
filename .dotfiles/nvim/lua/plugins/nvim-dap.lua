local js_based_languages = {
	"typescript",
	"javascript",
	"typescriptreact",
	"javascriptreact",
	"vue",
}

return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			{
				"leoluz/nvim-dap-go",
				config = function()
					require('dap-go').setup({
						dap_configurations = {
							{
								type = "go",
								name = "Attach remote",
								mode = "remote",
								request = "attach",
							},
						},
						-- options related to running closest test
						tests = {
							-- enables verbosity when running the test.
							verbose = true,
						},
						-- delve configurations
						delve = {
							port = "38697", -- default delve port, for attach remote
						},
					})
				end,
			},
			{
				"microsoft/vscode-js-debug",
				-- After install, build it and rename the dist directory to out
				build =
				"npm install --legacy-peer-deps --no-save && npx gulp vsDebugServerBundle && rm -rf out && mv dist out",
				version = "1.*",
			},
			{
				"mxsdev/nvim-dap-vscode-js",
				config = function()
					---@diagnostic disable-next-line: missing-fields
					require("dap-vscode-js").setup({
						-- Path of node executable. Defaults to $NODE_PATH, and then "node"
						-- node_path = "node",

						-- Path to vscode-js-debug installation.
						debugger_path = vim.fn.resolve(vim.fn.stdpath("data") .. "/lazy/vscode-js-debug"),

						-- Command to use to launch the debug server. Takes precedence over "node_path" and "debugger_path"
						-- debugger_cmd = { "js-debug-adapter" },

						-- which adapters to register in nvim-dap
						adapters = {
							"chrome",
							"pwa-node",
							"pwa-chrome",
							"pwa-msedge",
							"pwa-extensionHost",
							"node-terminal",
						},

						-- Path for file logging
						-- log_file_path = "(stdpath cache)/dap_vscode_js.log",

						-- Logging level for output to file. Set to false to disable logging.
						-- log_file_level = false,

						-- Logging level for output to console. Set to false to disable console output.
						-- log_console_level = vim.log.levels.DEBUG,
					})
				end,
			},
			{ "igorlfs/nvim-dap-view" },
			{ "theHamsta/nvim-dap-virtual-text" },
		},
		config = function()
			-- Setup virtual text
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

			-- -- Set up the signs for the debugger
			vim.fn.sign_define("DapStopped", { text = vim.g.vinux_diagnostics_signs_warning, texthl = "DiagnosticWarn" })
			vim.fn.sign_define("DapBreakpoint", { text = vim.g.vinux_diagnostics_signs_info, texthl = "DiagnosticInfo" })
			vim.fn.sign_define("DapBreakpointRejected",
				{ text = vim.g.vinux_diagnostics_signs_error, texthl = "DiagnosticError" })
			vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DiagnosticInfo" })
			vim.fn.sign_define("DapLogPoint", { text = ".>", texthl = "DiagnosticInfo" })

			local dap, dapgo = require("dap"), require('dap-go')

			-- 1) Make dap log everything (this is the big one)
			dap.set_log_level("TRACE")

			for _, language in ipairs(js_based_languages) do
				dap.configurations[language] = {
					{
						type = "pwa-node",
						request = "launch",
						name = "Next.js Node Debug",
						runtimeExecutable = "${workspaceFolder}/node_modules/next/dist/bin/next",
						cwd = "${workspaceFolder}/packages/web",
						sourceMaps = true,
					},

					-- Debug single nodejs files
					{
						type = "pwa-node",
						request = "launch",
						name = "Launch file",
						program = "${file}",
						cwd = vim.fn.getcwd(),
						sourceMaps = true,
					},
					-- Debug web applications (client side)
					{
						type = "pwa-chrome", -- Can also use 'chrome' for Chrome, or 'pwa-chrome' for Chromium
						request = "attach", -- Change from 'launch' to 'attach'
						name = "Attach to Chromium",
						port = 9222, -- This should match the port you specified when launching Chromium
						webRoot = vim.fn.getcwd(), -- Make sure this points to the root of your project
						protocol = "inspector",
						sourceMaps = true,
						userDataDir = false, -- Optional, set it if you want to avoid session conflicts
					},
					-- Debug web applications (client side)
					{
						type = "pwa-chrome",
						request = "launch",
						port = 9222,
						name = "Launch & Debug Chrome",
						url = function()
							local co = coroutine.running()
							return coroutine.create(function()
								vim.ui.input({
									prompt = "Enter URL: ",
									default = "http://localhost:3000",
								}, function(url)
									if url == nil or url == "" then
										return
									else
										coroutine.resume(co, url)
									end
								end)
							end)
						end,
						webRoot = vim.fn.getcwd(),
						protocol = "inspector",
						sourceMaps = true,
						userDataDir = false,
					},
				}
			end

			-- Set up the keybindings
			-- help dap.txt
			vim.keymap.set('n', '<leader>dd', function() dap.disconnect() end)
			vim.keymap.set('n', '<leader>dr', function() dap.restart() end)
			vim.keymap.set('n', '<leader>dx', function() dap.repl.open() end)
			vim.keymap.set('n', '<leader>dt', function() dapgo.debug_test() end)
			vim.keymap.set('n', '<leader>dl', function() dapgo.debug_last_test() end)
			vim.keymap.set('n', '<leader>dc', function()
				require('dap.ext.vscode').json_decode = require('json5').parse
				dap.continue()
			end)
			vim.keymap.set('n', '<leader>dp', function() dap.pause() end)
			vim.keymap.set('n', '<leader>db', function() dap.toggle_breakpoint() end)
			vim.keymap.set('n', '<leader>dn', function() dap.step_over() end)
			vim.keymap.set('n', '<leader>do', function() dap.step_out() end)
			vim.keymap.set('n', '<leader>di', function() dap.step_into() end)
		end
	},
}
