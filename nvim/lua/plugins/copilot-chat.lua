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
	config = function(_, opts)
		local chat = require("CopilotChat")
		chat.setup(opts)

		local select = require("CopilotChat.select")
		vim.api.nvim_create_user_command("CopilotChatVisual", function(args)
			chat.ask(args.args, { selection = select.visual })
		end, { nargs = "*", range = true })

		-- Inline chat with Copilot
		vim.api.nvim_create_user_command("CopilotChatInline", function(args)
			chat.ask(args.args, {
				selection = select.visual,
				window = {
					layout = "float",
					relative = "cursor",
					width = 1,
					height = 0.4,
					row = 1,
				},
			})
		end, { nargs = "*", range = true })

		-- Restore CopilotChatBuffer
		vim.api.nvim_create_user_command("CopilotChatBuffer", function(args)
			chat.ask(args.args, { selection = select.buffer })
		end, { nargs = "*", range = true })

		-- Custom buffer for CopilotChat
		vim.api.nvim_create_autocmd("BufEnter", {
			pattern = "copilot-*",
			callback = function()
				vim.opt_local.relativenumber = true
				vim.opt_local.number = true

				-- Get current filetype and set it to markdown if the current filetype is copilot-chat
				local ft = vim.bo.filetype
				if ft == "copilot-chat" then
					vim.bo.filetype = "markdown"
				end
			end,
		})
	end,
}
