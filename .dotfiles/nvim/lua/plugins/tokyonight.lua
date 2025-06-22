-- A dark and light Neovim theme written in Lua ported from the Visual Studio Code TokyoNight theme
-- https://github.com/folke/tokyonight.nvim
return {
	-- the colorscheme should be available when starting Neovim
	{
		"folke/tokyonight.nvim",
		tag = "stable",
		lazy = false, -- make sure we load this during startup if it is your main colorscheme
		priority = 1000, -- make sure to load this before all the other start plugins
		config = function()
			-- load the colorscheme here
			vim.cmd([[colorscheme tokyonight]])
		end,
	}
}
