return {
	-- https://github.com/stevearc/conform.nvim
	"stevearc/conform.nvim",
	enabled = true,
	event = { "BufNewFile", "BufReadPre" },
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				typescript = { "prettierd" },
				typescriptreact = { "prettierd" },
				css = { "prettierd" },
				html = { "prettierd" },
				json = { "prettierd" },
				yaml = { "prettierd" },
				markdown = { "prettierd" },
				lua = { "stylua" },
				go = { "gofumpt", "goimports" },
				sh = { "shfmt" },
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
