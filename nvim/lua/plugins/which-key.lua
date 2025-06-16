return {
	-- https://github.com/folke/which-key.nvim
	"folke/which-key.nvim",
	enabled = true,
	branch = "main",
	event = "VeryLazy",
	opts = {
		preset = "modern",
	},
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Local Keymaps (which-key)",
		},
	},
}
