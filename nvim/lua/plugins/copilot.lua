return {
	-- https://github.com/zbirenbaum/copilot.lua
	"zbirenbaum/copilot.lua",
	enabled = true,
	branch = "master",
	cmd = "Copilot",
	event = "BufReadPost",
	config = function()
		require("copilot").setup({
			copilot_model = "gpt-4.1",
			suggestion = {
				enabled = true,
				auto_trigger = true,
				hide_during_completion = false,
				debounce = 75,
				trigger_on_accept = false,
				keymap = {
					accept = "<TAB>",
					accept_word = false,
					accept_line = false,
					next = "<M-]>",
					prev = "<M-[>",
					dismiss = "<C-]>",
				},
			},
			panel = {
				enabled = false,
			},
			filetypes = {
				["*"] = true,
			},
			workspace_folders = {
				"~/projects",
			},
			root_dir = function()
				return vim.fs.dirname(vim.fs.find(".git", { upward = true })[1])
			end,
		})
	end,
}
