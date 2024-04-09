return {
	-- https://github.com/williamboman/mason.nvim
	"williamboman/mason.nvim",
	enabled = true,
	opts = {
		ensure_installed = {
			"eslint-lsp",
			"gopls",
			"lua-language-server",
			"prettierd",
			"typescript-language-server",
		},
	},
}
