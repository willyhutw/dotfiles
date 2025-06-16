return {
	-- https://github.com/lewis6991/gitsigns.nvim
	"lewis6991/gitsigns.nvim",
	enabled = true,
	branch = "main",
	opts = {
		on_attach = function(bufnr)
			local gitsigns = require("gitsigns")

			local function map(mode, l, r, opts)
				opts = opts or {}
				opts.buffer = bufnr
				vim.keymap.set(mode, l, r, opts)
			end

			-- Navigation
			map("n", "]c", function()
				if vim.wo.diff then
					vim.cmd.normal({ "]c", bang = true })
				else
					gitsigns.nav_hunk("next")
				end
			end, { desc = "Jump to next git [c]hange" })

			map("n", "[c", function()
				if vim.wo.diff then
					vim.cmd.normal({ "[c", bang = true })
				else
					gitsigns.nav_hunk("prev")
				end
			end, { desc = "Jump to previous git [c]hange" })

			-- Actions
			-- visual mode
			map("v", "<leader>hs", function()
				gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, { desc = "[h]unk [s]tage" })
			map("v", "<leader>hr", function()
				gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
			end, { desc = "[h]unk [r]eset" })
			-- normal mode
			map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "[h]unk [p]review" })
			map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "[h]unk [s]tage" })
			map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "[h]unk [r]eset" })
			map("n", "<leader>hu", gitsigns.undo_stage_hunk, { desc = "[h]unk [u]ndo stage" })
			map("n", "<leader>hS", gitsigns.stage_buffer, { desc = "buffer [S]tage" })
			map("n", "<leader>hR", gitsigns.reset_buffer, { desc = "buffer [R]eset" })
			map("n", "<leader>hb", gitsigns.blame_line, { desc = "[b]lame line" })
			map("n", "<leader>hd", gitsigns.diffthis, { desc = "[d]iff" })
		end,
	},
}
