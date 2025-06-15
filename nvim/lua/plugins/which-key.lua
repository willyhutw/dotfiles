return {
	-- https://github.com/folke/which-key.nvim
	"folke/which-key.nvim",
	enabled = true,
	branch = "main",
	event = "VeryLazy",
	opts = {
		preset = "classic", -- "classic" | "modern" | "helix"
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
