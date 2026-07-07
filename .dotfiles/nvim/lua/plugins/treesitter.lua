-- The goal of nvim-treesitter is both to provide a simple and easy way to use the interface for tree-sitter in Neovim and to provide some basic functionality such as highlighting based on it.
-- https://github.com/nvim-treesitter/nvim-treesitter
return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		require('nvim-treesitter').install {
			'python',
			'markdown',
			'json',
			'javascript',
			'typescript',
			'c',
			'lua',
			'rust',
			'go',
			'proto',
			'nix',
		}
	end
}
