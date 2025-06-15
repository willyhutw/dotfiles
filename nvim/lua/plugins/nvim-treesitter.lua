return {
	-- https://github.com/nvim-treesitter/nvim-treesitter
	"nvim-treesitter/nvim-treesitter",
	enabled = true,
	version = "v0.10.0",
	event = { "BufNewFile", "BufReadPre" },
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"bash",
				"css",
				"diff",
				"dockerfile",
				"go",
				"html",
				"javascript",
				"json",
				"lua",
				"markdown",
				"python",
				"regex",
				"rust",
				"toml",
				"tsx",
				"typescript",
				"yaml",
			},
			auto_install = true,
			highlight = {
				enable = true,
				use_languagetree = true,
			},
			indent = { enable = true },
		})
	end,
}
