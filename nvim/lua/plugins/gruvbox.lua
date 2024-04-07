return {
	"ellisonleao/gruvbox.nvim",
	version = "*",
	enabled = true,
	lazy = false,
	config = function()
		require("gruvbox").setup({
			-- https://github.com/ellisonleao/gruvbox.nvim?tab=readme-ov-file#configuration
			terminal_colors = true,
			undercurl = true,
			underline = true,
			bold = true,
			italic = {
				strings = true,
				emphasis = true,
				comments = true,
				operators = false,
				folds = true,
			},
			strikethrough = true,
			invert_selection = false,
			invert_signs = false,
			invert_tabline = false,
			invert_intend_guides = false,
			inverse = true,
			contrast = "", -- can be 'hard', 'soft' or empty string
			palette_overrides = {},
			overrides = {},
			dim_inactive = false,
			transparent_mode = false,
		})
		vim.cmd("colorscheme gruvbox")
	end,
}
