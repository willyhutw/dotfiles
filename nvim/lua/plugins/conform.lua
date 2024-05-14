return {
	-- https://github.com/stevearc/conform.nvim
	"stevearc/conform.nvim",
	enabled = true,
	event = { "BufNewFile", "BufReadPre" },
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				yaml = { "yamlfmt" },
				lua = { "stylua" },
				go = { "gofumpt", "goimports-reviser" },
				sh = { "shfmt" },
				python = { "black" },
			},
			format_on_save = {
				timeout_ms = 3000,
				async = false,
				quiet = false,
				lsp_fallback = true,
			},
		})
	end,
}
