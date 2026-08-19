return {
	-- https://github.com/neovim/nvim-lspconfig
	"neovim/nvim-lspconfig",
	enabled = true,
	version = "v2.3.0",
	event = { "BufNewFile", "BufReadPre" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
	},
	config = function()
		vim.lsp.config("lua_ls", {
			settings = {
				Lua = {
					runtime = {
						version = "LuaJIT",
					},
					diagnostics = {
						globals = { "vim" },
					},
					workspace = {
						checkThirdParty = false,
					},
					telemetry = {
						enable = false,
					},
				},
			},
		})
		-- other lsp configurations can be added below
	end,
}
