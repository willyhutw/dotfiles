return {
  -- https://github.com/nvim-lualine/lualine.nvim
  "nvim-lualine/lualine.nvim",
  enabled = true,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("lualine").setup({})
  end,
}
