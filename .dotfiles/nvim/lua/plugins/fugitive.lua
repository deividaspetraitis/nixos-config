return {
    "tpope/vim-fugitive",
    config = function()
        vim.keymap.set("n", "gs", vim.cmd.Git)
    end
}
