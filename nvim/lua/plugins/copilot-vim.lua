return {
	-- https://github.com/github/copilot.vim
	-- https://github.com/jellydn/lazy-nvim-ide/blob/main/lua/plugins/extras/copilot-vim.lua
	{
		"github/copilot.vim",
		event = "VeryLazy",
		config = function()
			vim.g.copilot_filetypes = {
				["TelescopePrompt"] = false,
			}
		end,
	},
}
