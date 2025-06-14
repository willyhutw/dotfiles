return {
	-- https://github.com/williamboman/mason-lspconfig.nvim
	"williamboman/mason-lspconfig.nvim",
	enabled = true,
	version = "v2.0.0",
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
				"pyright",
			},
			automatic_installation = true,
		})
	end,
}
