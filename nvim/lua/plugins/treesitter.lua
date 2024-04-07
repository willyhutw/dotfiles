return {
  'nvim-treesitter/nvim-treesitter',
  version = '*',
  enabled = true,
  build = ':TSUpdate',
  config = function()
    local configs = require('nvim-treesitter.configs')
    configs.setup({
      ensure_installed = {
        'bash',
        'go',
        'html',
        'javascript',
        'json',
        'lua',
        'markdown',
        'toml',
        'tsx',
        'typescript',
        'vim',
        'vimdoc',
        'yaml',
      },
      sync_install = false,
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
