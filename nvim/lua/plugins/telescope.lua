return {
	-- https://github.com/nvim-telescope/telescope.nvim
	"nvim-telescope/telescope.nvim",
	enabled = true,
	branch = "master",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"folke/todo-comments.nvim",
	},
	config = function()
		local keymap = vim.keymap
		local builtin = require("telescope.builtin")
		keymap.set("n", "<leader>ff", builtin.find_files, {})
		keymap.set("n", "<leader>fg", builtin.live_grep, {})
		keymap.set("n", "<leader>fb", builtin.buffers, {})
		keymap.set("n", "<leader>fh", builtin.help_tags, {})
		keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<CR>", {})
	end,
}
