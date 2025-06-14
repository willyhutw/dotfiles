return {
	-- https://github.com/williamboman/mason.nvim
	"williamboman/mason.nvim",
	enabled = true,
	version = "v2.0.0",
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
