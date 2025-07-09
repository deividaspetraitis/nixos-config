-- avante.nvim is a Neovim plugin designed to emulate the behaviour of the Cursor AI IDE.
-- It provides users with AI-driven code suggestions and the ability to apply these recommendations directly to their source files with minimal effort.
-- https://github.com/yetone/avante.nvim
return {
	"yetone/avante.nvim",
	event = "VeryLazy",
	lazy = false,
	-- tag = "v0.0.25",
	--
	version = false,                    -- Never set this value to "*"! Never!
	opts = {
		auto_suggestions_provider = "claude", -- Since auto-suggestions are a high-frequency operation and therefore expensive, it is recommended to specify an inexpensive provider or even a free provider: copilot
		provider = "claude",            -- Recommend using Claude
		providers = {
			claude = {
				endpoint = "https://api.anthropic.com",
				model = "claude-sonnet-4-20250514",
				timeout = 30000, -- Timeout in milliseconds
				extra_request_body = {
					temperature = 0.75,
					max_tokens = 20480,
				},
			},
		},
		behaviour = {
			auto_suggestions = false, -- Experimental stage
		},
	},
	-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
	-- ⚠️ must add this setting! ! !
	build = function()
		-- conditionally use the correct build system for the current OS
		if vim.fn.has("win32") == 1 then
			return "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
		else
			return "make"
		end
	end,
	-- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
	dependencies = {
		"stevearc/dressing.nvim",
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		require('avante').setup {
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
