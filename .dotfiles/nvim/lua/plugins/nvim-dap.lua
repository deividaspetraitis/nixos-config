return {
	{
		"Joakker/lua-json5",
		build = "./install.sh"
	},
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"nvim-telescope/telescope-dap.nvim",
			"leoluz/nvim-dap-go",
		},
		config = function()
			-- Load the dap extension for telescope
			require('telescope').load_extension('dap')
			require("dapui").setup()
			require('dap-go').setup()
			-- TODO:
			-- require('dap.ext.vscode').json_decode = require 'json5'.parse
			require('dap.ext.vscode').load_launchjs(nil, {})
		end
	},
}
