return {
	-- https://github.com/stevearc/conform.nvim
	"stevearc/conform.nvim",
	enabled = true,
	branch = "master",
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				css = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				lua = { "stylua" },
				rust = { "rustfmt" },
				sh = { "shfmt" },
				yaml = { "yamlfmt" },
				terraform = { "terraform_fmt" },
			},
			formatters = {
				yamlfmt = {
					args = { "-formatter", "retain_line_breaks=true", "indentless_arrays=true", "-" },
				},
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
