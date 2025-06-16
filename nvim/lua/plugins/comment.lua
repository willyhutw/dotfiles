return {
	-- https://github.com/numToStr/Comment.nvim
	"numToStr/Comment.nvim",
	enabled = true,
	branch = "master",
	config = function()
		require("Comment").setup({})
	end,
}
