return {
	-- https://github.com/williamboman/mason.nvim
	"williamboman/mason.nvim",
	enabled = true,
	branch = "main",
	config = function()
		require("mason").setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})
	end,
}
