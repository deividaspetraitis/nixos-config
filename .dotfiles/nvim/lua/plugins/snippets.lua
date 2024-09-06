return {
	"L3MON4D3/LuaSnip",

	dependencies = { "rafamadriz/friendly-snippets" },

	-- Actual mappings are in lsp.lua
	config = function()
		require('luasnip.loaders.from_vscode').lazy_load()
	end,
}
