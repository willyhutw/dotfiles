return {
	-- https://github.com/akinsho/bufferline.nvim
	"akinsho/bufferline.nvim",
	enabled = true,
	branch = "main",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		options = {
			indicator = {
				style = "underline",
			},
			separator_style = "slope",
			diagnostics = "nvim_lsp",
			diagnostics_indicator = function(_, _, diag)
				local ret = (diag.error and " " .. diag.error or "")
					.. (diag.warning and " " .. diag.warning or "")
				return vim.trim(ret)
			end,
		},
	},
}
