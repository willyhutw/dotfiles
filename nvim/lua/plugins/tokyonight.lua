return {
	"folke/tokyonight.nvim",
	version = "*",
	enabled = false,
	lazy = false,
	config = function()
		require("tokyonight").setup({
			-- https://github.com/folke/tokyonight.nvim?tab=readme-ov-file#%EF%B8%8F-configuration
			style = "night",
			light_style = "day",
			transparent = false,
			terminal_colors = true,
			styles = {
				comments = { italic = true },
				keywords = { italic = true },
				functions = {},
				variables = {},
				sidebars = "dark",
				floats = "dark",
			},
			sidebars = { "qf", "help" },
			day_brightness = 0.3,
			hide_inactive_statusline = false,
			dim_inactive = false,
			lualine_bold = false,
		})
		vim.cmd("colorscheme tokyonight")
	end,
}
