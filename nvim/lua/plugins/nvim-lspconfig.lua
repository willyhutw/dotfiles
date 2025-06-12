return {
	-- https://github.com/neovim/nvim-lspconfig
	"neovim/nvim-lspconfig",
	event = { "BufNewFile", "BufReadPre" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
	},
	config = function()
		local on_attach = require("plugins.nvim-lspconfig").on_attach
		-- local capabilities = require("plugins.lspconfig").capabilities
		local capabilities = require("cmp_nvim_lsp").default_capabilities()
		local lspconfig = require("lspconfig")

		local servers = {
			"lua_ls",
			"bashls",
			"gopls",
			"ts_ls",
			"pyright",
		}

		for _, lsp in ipairs(servers) do
			lspconfig[lsp].setup({
				on_attach = on_attach,
				capabilities = capabilities,
			})
		end

		-- Extra `global vim` setting
		lspconfig["lua_ls"].setup({
			settings = {
				Lua = {
					runtime = {
						-- Tell the language server which version of Lua you're using
						version = "LuaJIT",
					},
					diagnostics = {
						globals = { "vim" },
					},
					workspace = {
						-- Make the server aware of Neovim runtime files
						library = vim.api.nvim_get_runtime_file("", true),
					},
					telemetry = {
						enable = false,
					},
				},
			},
		})

		lspconfig["pyright"].setup({
			filetypes = { "python" },
		})
	end,
}
