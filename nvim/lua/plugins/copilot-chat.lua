local defaultPrompts = {
	Explain = {
		prompt = "Write an explanation for the selected code as paragraphs of text.",
		system_prompt = "COPILOT_EXPLAIN",
	},
	Review = {
		prompt = "Review the selected code.",
		system_prompt = "COPILOT_REVIEW",
	},
	Fix = {
		prompt = "There is a problem in this code. Identify the issues and rewrite the code with fixes. Explain what was wrong and how your changes address the problems.",
	},
	Optimize = {
		prompt = "Optimize the selected code to improve performance and readability. Explain your optimization strategy and the benefits of your changes.",
	},
	Docs = {
		prompt = "Please add documentation comments to the selected code.",
	},
	Tests = {
		prompt = "Please generate tests for my code.",
	},
	Commit = {
		prompt = "Write commit message for the change with commitizen convention. Keep the title under 50 characters and wrap message at 72 characters. Format as a gitcommit code block.",
		context = "git:staged",
	},
}

return {
	-- https://github.com/CopilotC-Nvim/CopilotChat.nvim
	-- https://github.com/jellydn/lazy-nvim-ide/blob/main/lua/plugins/extras/copilot-chat-v2.lua
	"CopilotC-Nvim/CopilotChat.nvim",
	enabled = true,
	branch = "main",
	dependencies = {
		{ "nvim-lua/plenary.nvim" },
		{ "nvim-telescope/telescope-ui-select.nvim" },
	},
	event = "VeryLazy",
	build = "make tiktoken",
	cmd = "CopilotChat",
	keys = {
		{ "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
		-- Toggle Copilot Chat Vsplit
		{ "<leader>av", "<cmd>CopilotChatToggle<cr>", desc = "CopilotChat - Toggle" },
		-- Show prompts actions
		{
			"<leader>ap",
			function()
				require("CopilotChat").select_prompt({ context = { "buffers" } })
			end,
			desc = "CopilotChat - Prompt actions",
		},
		{
			"<leader>ap",
			function()
				require("CopilotChat").select_prompt()
			end,
			mode = "x",
			desc = "CopilotChat - Prompt actions",
		},
		-- Clear buffer and chat history
		{ "<leader>al", "<cmd>CopilotChatReset<cr>", desc = "CopilotChat - Clear buffer and chat history" },
	},
	opts = {
		temperature = 0.1,
		window = {
			layout = "vertical",
			width = 0.4,
		},
		auto_insert_mode = false,
		insert_at_end = true,
		chat_autocomplete = true,
		question_header = "#  User ",
		answer_header = "#   Copilot ",
		prompts = defaultPrompts,
	},
}
