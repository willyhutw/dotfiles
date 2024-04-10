return {
	-- https://github.com/williamboman/mason.nvim
	"williamboman/mason.nvim",
	enabled = true,
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
