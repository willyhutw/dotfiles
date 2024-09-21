return {
  -- https://github.com/neovim/nvim-lspconfig
  "neovim/nvim-lspconfig",
  event = { "BufNewFile", "BufReadPre" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
  },
  config = function()
    local on_attach = require("plugins.lspconfig").on_attach
    -- local capabilities = require("plugins.lspconfig").capabilities
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    local lspconfig = require("lspconfig")

    local servers = {
      "bashls",
      "gopls",
      "lua_ls",
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
          diagnostics = {
            globals = { "vim" },
          },
        },
      },
    })

    lspconfig["pyright"].setup({
      filetypes = { "python" },
    })
  end,
}
