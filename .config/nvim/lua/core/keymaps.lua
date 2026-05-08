vim.keymap.set("n", "<leader>l", "<cmd>Lazy<cr>")
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>")

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
	{ "<leader>h", group = "+git", mode = { "n", "v" } },
	{ "<leader>hp", "<cmd>Gitsigns preview_hunk<CR>", desc = "[h]unk [p]review", mode = "n" },
	{ "<leader>hs", "<cmd>Gitsigns stage_hunk<CR>", desc = "[h]unk [s]tage", mode = { "n", "v" } },
	{ "<leader>hr", "<cmd>Gitsigns reset_hunk<CR>", desc = "[h]unk [r]eset", mode = { "n", "v" } },
	{ "<leader>hu", "<cmd>Gitsigns undo_stage_hunk<CR>", desc = "[h]unk [u]ndo stage", mode = "n" },
	{ "<leader>hS", "<cmd>Gitsigns stage_buffer<CR>", desc = "buffer [S]tage", mode = "n" },
	{ "<leader>hR", "<cmd>Gitsigns reset_buffer<CR>", desc = "buffer [R]eset", mode = "n" },
	{ "<leader>hb", "<cmd>Gitsigns blame_line<CR>", desc = "[b]lame line", mode = "n" },
	{ "<leader>hd", "<cmd>Gitsigns diffthis<CR>", desc = "[d]iff", mode = "n" },
	{ "]c", "<cmd>Gitsigns next_hunk<CR>", desc = "next git [c]hange", mode = "n" },
	{ "[c]", "<cmd>Gitsigns prev_hunk<CR>", desc = "previous git [c]hange", mode = "n" },
})
