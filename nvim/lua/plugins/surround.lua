return {
	"kylechui/nvim-surround",
	version = "*",
	enabled = true,
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("nvim-surround").setup({})
	end,
}
