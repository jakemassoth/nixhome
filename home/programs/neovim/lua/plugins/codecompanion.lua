require("copilot").setup({
	panel = { enabled = false },
	suggestion = { enabled = false },
})

require("codecompanion").setup({
	adapters = {
		copilot = function()
			return require("codecompanion.adapters").extend("copilot", {
				schema = {
					model = {
						default = "claude-3.7-sonnet-thought",
					},
				},
			})
		end,
		gemini = function()
			return require("codecompanion.adapters").extend("gemini", {
				env = {
					api_key = "cmd: cat ~/GEMINI_API_KEY | tr -d '\n'",
				},
			})
		end,
	},
	strategies = {
		chat = {
			slash_commands = {
				["file"] = {
					callback = "strategies.chat.slash_commands.file",
					description = "Select a file using Telescope",
					opts = {
						provider = "telescope",
						contains_code = true,
					},
				},
				["buffer"] = {
					callback = "strategies.chat.slash_commands.buffer",
					description = "Select a buffer using Telescope",
					opts = {
						provider = "telescope",
						contains_code = true,
					},
				},
			},
			adapter = "copilot",
		},
		inline = {
			adapter = "copilot",
		},
	},
	display = {
		action_palette = { provider = "telescope" },
	},
	prompt_library = {
		["Codebase Context"] = {
			strategy = "chat",
			description = "Chat with codebase context",
			opts = {
				index = 11,
				is_slash_cmd = false,
				auto_submit = false,
				short_name = "codebase_context",
			},
			references = {
				{
					type = "file",
					path = {
						"repomix-output.xml",
						".airules",
					},
				},
			},
			prompts = {
				{
					role = "user",
					content = "I have shared my entire codebase with you in repomix-output.xml, please review it before proceeding. I have also shared a set of rules and description about the project in .airules. Please carefully review that as well.",
					opts = {
						contains_code = true,
					},
				},
			},
		},
	},
})
vim.keymap.set({ "n", "v" }, "<leader>c", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<leader><CR>", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

-- Expand 'cc' into 'CodeCompanion' in the command line
vim.cmd([[cab cc CodeCompanion]])
