return {
	-- https://github.com/olexsmir/gopher.nvim
	"olexsmir/gopher.nvim",
	enabled = true,
	event = { "BufNewFile", "BufReadPre" },
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		require("gopher").setup({})
	end,
}
