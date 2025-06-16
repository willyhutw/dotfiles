return {
	-- https://github.com/akinsho/bufferline.nvim
	"akinsho/bufferline.nvim",
	enabled = true,
	branch = "main",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		options = {
			mode = "tabs", -- 'buffers' | 'tabs'
			separator_style = "slope", -- "slant" | "slope" | "thick" | "thin"
			diagnostics = "nvim_lsp",
			diagnostics_indicator = function(_, _, diag)
				local ret = (diag.error and " " .. diag.error or "")
					.. (diag.warning and " " .. diag.warning or "")
				return vim.trim(ret)
			end,
		},
	},
}
