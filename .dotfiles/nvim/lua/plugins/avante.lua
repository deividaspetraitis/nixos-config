return {
	"yetone/avante.nvim",
	event = "VeryLazy",
	lazy = false,
	tag = "v0.0.21",
	opts = {
		-- add any opts here
	},
	-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
	build = "make",
	-- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
	dependencies = {
		"stevearc/dressing.nvim",
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
	},

	config = function()
		require('avante').setup {
			provider = "claude",         -- Recommend using Claude
			auto_suggestions_provider = "claude", -- Since auto-suggestions are a high-frequency operation and therefore expensive, it is recommended to specify an inexpensive provider or even a free provider: copilot
			claude = {
				endpoint = "https://api.anthropic.com",
				model = "claude-3-5-sonnet-20240620",
				temperature = 0,
				max_tokens = 4096,
			},
			behaviour = {
				auto_suggestions = false, -- Experimental stage
			},
			mappings = {
				submit = {
					normal = "<CR>",
					insert = "<C-y>",
				},
				suggestion = {
					accept = "<C-l>",
					next = "<C-n>",
					prev = "<C-p>",
					dismiss = "<C-q>",
				},
			},
		}
	end
}
