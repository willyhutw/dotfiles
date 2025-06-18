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
				gitcommit = false,
				gitrebase = false,
				help = false,
				["."] = false,
			},
			workspace_folders = {},
			root_dir = function()
				return vim.fs.dirname(vim.fs.find(".git", { upward = true })[1])
			end,
			-- Override `should_attach` to allow suggestions in CopilotChat
			should_attach = function(bufnr)
				-- allow attach to CopilotChat buffer
				if vim.bo[bufnr].filetype == "copilot-chat" then
					return true
				end

				-- Down below is the default behavior for other buffers
				if not vim.bo.buflisted then
					return false
				end

				if vim.bo.buftype ~= "" then
					return false
				end

				return true
			end,
		})
	end,
}
