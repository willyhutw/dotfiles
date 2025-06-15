-- https://github.com/nvim-lua/kickstart.nvim/blob/master/init.lua

vim.keymap.set("n", "<leader>l", "<cmd>Lazy<cr>")
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>")

-- Keybinds to make split navigation easier.
-- Use CTRL+<hjkl> to switch between windows
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Clear highlights on search when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Register keymap to the 'which-key' plugin
local wk = require("which-key")
wk.add({
	{ "<leader>h", group = "+git" },
	{ "<leader>hp", "<cmd>Gitsigns preview_hunk<CR>", desc = "git [p]review hunk" },
	{ "<leader>hs", "<cmd>Gitsigns stage_hunk<CR>", desc = "git [s]tage hunk" },
	{ "<leader>hu", "<cmd>Gitsigns undo_stage_hunk<CR>", desc = "git [u]ndo stage hunk" },
	{ "<leader>hr", "<cmd>Gitsigns reset_hunk<CR>", desc = "git [r]eset hunk" },
	{ "<leader>hS", "<cmd>Gitsigns stage_buffer<CR>", desc = "git [S]tage buffer" },
	{ "<leader>hR", "<cmd>Gitsigns reset_buffer<CR>", desc = "git [R]eset buffer" },
	{ "<leader>hb", "<cmd>Gitsigns blame_line<CR>", desc = "git [b]lame line" },
	{ "<leader>hd", "<cmd>Gitsigns diffthis<CR>", desc = "git [d]iff" },
})
