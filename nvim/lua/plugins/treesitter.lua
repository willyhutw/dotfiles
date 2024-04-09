return {
  -- https://github.com/nvim-treesitter/nvim-treesitter
  "nvim-treesitter/nvim-treesitter",
  enabled = true,
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "bash",
        "go",
        "html",
        "json",
        "lua",
        "markdown",
        "toml",
        "tsx",
        "typescript",
        "yaml",
      },
      sync_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
