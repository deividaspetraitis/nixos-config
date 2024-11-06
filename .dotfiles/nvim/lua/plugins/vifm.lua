return {
	"vifm/vifm.vim",
	tag = "v0.13",
	config = function()
		-- Use Vifm as the default file explorer
		vim.g.vifm_replace_netrw = 1

		-- Vifm leader mapping
		vim.api.nvim_set_keymap('n', '<leader>v', ':FloatermNew vifm<CR>', { noremap = true, silent = true })
	end
}
