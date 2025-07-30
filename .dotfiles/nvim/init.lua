require("settings")
require("remap")
require("config.lazy")

vim.api.nvim_create_autocmd("VimResume", {
  callback = function()
    vim.cmd("mode")
  end,
  desc = "Fix terminal redraw issues when returning to Neovim caused by hrsh7th/nvim-cmp in tmux terminal",
})

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		-- Buffer local mappings.
		-- See `:help vim.lsp.*` for documentation on any of the below functions
		local opts = { buffer = ev.buf, silent = true }

		-- set keybinds
		opts.desc = "Fromat buffer"
		vim.keymap.set("n", "<F5>", function() vim.lsp.buf.format() end, opts)

		opts.desc = "Show LSP references"
		vim.keymap.set("n", "<localleader>gr", "<cmd>Telescope lsp_references<CR>", opts)

		opts.desc = "Go to declaration"
		vim.keymap.set("n", "gd", vim.lsp.buf.declaration, opts)

		opts.desc = "Show LSP definitions"
		vim.keymap.set("n", "<localleader>gd", "<cmd>Telescope lsp_definitions<CR>", opts)

		opts.desc = "Show LSP implementations"
		vim.keymap.set("n", "<localleader>gi", "<cmd>Telescope lsp_implementations<CR>", opts)

		opts.desc = "Show LSP type definitions"
		vim.keymap.set("n", "<localleader>gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

		opts.desc = "See available code actions"
		vim.keymap.set({ "n", "v" }, "<localleader>q", vim.lsp.buf.code_action, opts)

		opts.desc = "Smart rename"
		vim.keymap.set("n", "<localleader>r", vim.lsp.buf.rename, opts)

		opts.desc = "Show buffer diagnostics"
		vim.keymap.set("n", "<localleader>d", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

		opts.desc = "Show project diagnostics"
		vim.keymap.set("n", "<localleader>D", "<cmd>Telescope diagnostics<CR>", opts)

		opts.desc = "Go to previous diagnostic"
		vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

		opts.desc = "Go to next diagnostic"
		vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

		opts.desc = "Show documentation for what is under cursor"
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

		-- opts.desc = "Restart LSP"
		-- keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
	end,
})

-- If you don't want to turn 'hlsearch' on, but want to highlight all matches while searching
vim.api.nvim_create_augroup("vimrc-incsearch-highlight", { clear = true })
vim.api.nvim_create_autocmd({"CmdlineEnter"}, {
  group = "vimrc-incsearch-highlight",
  pattern = {"/", "\\?"},
  command = "set hlsearch"
})
vim.api.nvim_create_autocmd({"CmdlineLeave"}, {
  group = "vimrc-incsearch-highlight",
  pattern = {"/", "\\?"},
  command = "set nohlsearch"
})

-- Cursor line settings: Display cursor line only in an active window.
vim.api.nvim_create_augroup("CursorLineOnlyInActiveWindow", { clear = true })
vim.api.nvim_create_autocmd({"VimEnter", "WinEnter", "BufWinEnter"}, {
  group = "CursorLineOnlyInActiveWindow",
  command = "setlocal cursorline"
})
vim.api.nvim_create_autocmd("WinLeave", {
  group = "CursorLineOnlyInActiveWindow",
  command = "setlocal nocursorline"
})

-- Return to last edit position when opening files (You want this!)
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    if vim.fn.line("'\"") > 0 and vim.fn.line("'\"") <= vim.fn.line("$") then
      vim.cmd("normal! g`\"")
    end
  end
})

-- Quite a few people accidentally type "q:" instead of ":q" and get confused
-- by the command line window. Give a hint about how to get out.
vim.api.nvim_create_augroup("vimHints", { clear = true })
vim.api.nvim_create_autocmd("CmdwinEnter", {
  group = "vimHints",
  command = [[echohl Todo | echo 'You discovered the command-line window! You can close it with ":q".' | echohl None]]
})

-- Convenient command to see the difference between the current buffer and the file it was loaded from
if not vim.fn.exists(":DiffOrig") then
  vim.api.nvim_create_user_command('DiffOrig', function()
    vim.cmd('vert new')
    vim.cmd('set bt=nofile')
    vim.cmd('r ++edit #')
    vim.cmd('0d_')
    vim.cmd('diffthis')
    vim.cmd('wincmd p')
    vim.cmd('diffthis')
  end, {})
end
