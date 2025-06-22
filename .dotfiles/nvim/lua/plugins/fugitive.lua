-- Fugitive is the premier Vim plugin for Git
-- https://github.com/tpope/vim-fugitive
return {
    "tpope/vim-fugitive",
	tag = "v3.7",
    config = function()
        vim.keymap.set("n", "gs", vim.cmd.Git)
    end
}
