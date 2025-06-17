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
		{ "<leader>av", "<cmd>CopilotChatToggle<cr>", desc = "CopilotChat - Toggle" },
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
	},
	opts = {
		question_header = "#  User ",
		answer_header = "#   Copilot ",
		prompts = defaultPrompts,
		window = {
			width = 0.4,
		},
		temperature = 0.1,
		insert_at_end = true,
		auto_insert_mode = false,
		chat_autocomplete = false,
		mappings = {
			complete = {
				insert = false,
			},
		},
	},
}
