return {
	"github/copilot.vim",
	tag = "v1.40.0",
	config = function()
		-- Accept mapping
		vim.api.nvim_set_keymap('i', '<C-L>', 'copilot#Accept("<CR>")', { silent = true, script = true, expr = true })

		-- Disable default tab mapping
		vim.g.copilot_no_tab_map = true
	end
}
