return {
	-- https://github.com/ellisonleao/gruvbox.nvim
	"ellisonleao/gruvbox.nvim",
	enabled = true,
	config = function()
		require("gruvbox").setup({})
		vim.cmd("colorscheme gruvbox")
	end,
}
