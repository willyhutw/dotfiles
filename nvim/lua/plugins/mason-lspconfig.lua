return {
	-- https://github.com/williamboman/mason-lspconfig.nvim
	"williamboman/mason-lspconfig.nvim",
	enabled = true,
	branch = "main",
	dependencies = {
		"williamboman/mason.nvim",
		"neovim/nvim-lspconfig",
	},
	config = function()
		require("mason-lspconfig").setup({
			ensure_installed = {
				"bashls",
				"gopls",
				"lua_ls",
				"ts_ls",
			},
			automatic_installation = true,
		})
	end,
}
