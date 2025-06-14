return {
	-- https://github.com/ellisonleao/gruvbox.nvim
	"ellisonleao/gruvbox.nvim",
	enabled = true,
	branch = "main",
	config = function()
		require("gruvbox").setup({})
		vim.cmd("colorscheme gruvbox")
	end,
}
