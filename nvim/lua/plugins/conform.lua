return {
	-- https://github.com/stevearc/conform.nvim
	"stevearc/conform.nvim",
	enabled = true,
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
				rust = { "rustfmt" },
				sh = { "shfmt" },
				python = { "black" },
			},
			default_format_opts = {
				lsp_format = "fallback",
			},
			format_on_save = {
				timeout_ms = 3000,
				lsp_format = "fallback",
			},
			format_after_save = {
				lsp_format = "fallback",
			},
			log_level = vim.log.levels.ERROR,
			notify_on_error = true,
			notify_no_formatters = true,
		})
	end,
}
