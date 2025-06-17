return {
	-- https://github.com/nvim-tree/nvim-tree.lua
	"nvim-tree/nvim-tree.lua",
	enabled = true,
	version = "v1.13.0",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1
		require("nvim-tree").setup({
			update_focused_file = {
				enable = true,
				update_root = {
					enable = true,
				},
			},
		})
	end,
}
