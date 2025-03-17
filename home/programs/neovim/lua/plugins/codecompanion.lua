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
						default = "claude-3.7-sonnet",
					},
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
})
vim.keymap.set({ "n", "v" }, "<leader>c", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "<leader><CR>", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

-- Expand 'cc' into 'CodeCompanion' in the command line
vim.cmd([[cab cc CodeCompanion]])
