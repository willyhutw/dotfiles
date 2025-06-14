return {
	-- https://github.com/ellisonleao/gruvbox.nvim
	"ellisonleao/gruvbox.nvim",
	enabled = true,
	version = "v2.0.0",
	config = function()
		require("gruvbox").setup({})
		vim.cmd("colorscheme gruvbox")
	end,
}
