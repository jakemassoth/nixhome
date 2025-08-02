-- KEYMAPS
vim.g.mapleader = " "

local keymap = vim.keymap

keymap.set("n", "x", '"_x"') -- don't copy into the register when deleting with x

keymap.set("n", "<leader>+", "<C-a>")
keymap.set("n", "<leader>-", "<C-x>")

-- splitting windows
keymap.set("n", "<leader>sv", "<C-w>v") -- split vertially
keymap.set("n", "<leader>sh", "<C-w>s") -- split horizontally

keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true })
keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true })

-- greatest remap ever
keymap.set("x", "<leader>p", [["_dP]])

-- save file(s) on leader + wf
keymap.set("n", "<leader>wf", "<cmd>w<CR>")
keymap.set("n", "<leader>wa", "<cmd>wa<CR>")

-- Navigate between panes with Ctrl + hjkl
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left pane" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom pane" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top pane" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right pane" })

-- OPTIONS
local opt = vim.opt

-- set line numbers
opt.relativenumber = true
opt.number = true

-- tabs and indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

-- line wrapping
opt.wrap = false

-- search
opt.ignorecase = true
opt.smartcase = true

-- appearance
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"
opt.laststatus = 3
opt.spelllang = "en"

-- backspace
opt.backspace = "indent,eol,start"

-- clipboard
opt.clipboard:append("unnamedplus")

-- split windows
opt.splitright = true
opt.splitbelow = true

opt.winborder = "rounded"

-- LSP
keymap.set("n", "<leader>d", vim.diagnostic.open_float)

vim.lsp.enable({
	"html",
	"cssls",
	"nixd",
	"jsonls",
	"gopls",
	"svelte",
	"pyright",
	"tailwindcss",
	"intelephense",
	"graphql",
	"lua_ls",
	"elixirls",
	"terraformls",
	"vue_ls",
	"ts_ls",
	"helm_ls",
	"marksman",
	"astro",
	"bashls",
	"eslint",
	"rust_analyzer",
})

-- configure lua server (with special settings)
vim.lsp.config("lua_ls", {
	on_init = function(client)
		if client.workspace_folders then
			local path = client.workspace_folders[1].name
			if
				path ~= vim.fn.stdpath("config")
				and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
			then
				return
			end
		end

		client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
			runtime = {
				-- Tell the language server which version of Lua you're using (most
				-- likely LuaJIT in the case of Neovim)
				version = "LuaJIT",
				-- Tell the language server how to find Lua modules same way as Neovim
				-- (see `:h lua-module-load`)
				path = {
					"lua/?.lua",
					"lua/?/init.lua",
				},
			},
			-- Make the server aware of Neovim runtime files
			workspace = {
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME,
					-- Depending on the usage, you might want to add additional paths
					-- here.
					-- '${3rd}/luv/library'
					-- '${3rd}/busted/library'
				},
				-- Or pull in all of 'runtimepath'.
				-- NOTE: this is a lot slower and will cause issues when working on
				-- your own configuration.
				-- See https://github.com/neovim/nvim-lspconfig/issues/3189
				-- library = {
				--   vim.api.nvim_get_runtime_file('', true),
				-- }
			},
		})
	end,
	settings = {
		Lua = {},
	},
})

-- mini
require("mini.ai").setup()
require("mini.pairs").setup()
require("mini.surround").setup()
require("mini.statusline").setup()
require("mini.trailspace").setup()
require("mini.git").setup()
local MiniIcons = require("mini.icons")
local MiniPick = require("mini.pick")

MiniIcons.setup()
MiniIcons.mock_nvim_web_devicons()
MiniIcons.tweak_lsp_kind()

MiniPick.setup()
keymap.set("n", "<leader><space>", ":Pick files<CR>")
keymap.set("n", "<leader>/", ":Pick grep_live<CR>")
keymap.set("n", "<leader>fb", ":Pick buffers<CR>")
keymap.set("n", "<leader>fh", ":Pick help<CR>")
keymap.set("n", "<leader>fr", ":Pick resume<CR>")

-- use mini select for vim.ui.select
vim.ui.select = MiniPick.ui_select

-- treesitter
require("nvim-treesitter.configs").setup({
	highlight = {
		enable = true,
	},
	indent = { enable = true },
})

-- blink cmp
require("blink.cmp").setup({
	keymap = { preset = "default" },
	appearance = {
		use_nvim_cmp_as_default = true,
		nerd_font_variant = "mono",
	},
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
	},
	signature = { enabled = true },
})

-- Conform
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		rust = { "rustfmt" },
		javascript = { "prettier" },
		typescript = { "prettier" },
		vue = { "prettier" },
		graphql = { "prettier" },
		markdown = { "prettier" },
		php = { "pint" },
		nix = { "alejandra" },
	},
	format_on_save = function(bufnr)
		-- put stuff to ignore here
		local ignore_filetypes = {}
		if vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
			return
		end
		-- Disable with a global or buffer-local variable
		if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
			return
		end
		-- Disable autoformat for files in a certain path
		local bufname = vim.api.nvim_buf_get_name(bufnr)
		if bufname:match("/node_modules/") then
			return
		end
		-- ...additional logic...
		return { timeout_ms = 3000, lsp_format = "fallback" }
	end,
})

vim.api.nvim_create_user_command("FormatDisable", function(args)
	if args.bang then
		-- FormatDisable! will disable formatting just for this buffer
		vim.b.disable_autoformat = true
	else
		vim.g.disable_autoformat = true
	end
end, {
	desc = "Disable autoformat-on-save",
	bang = true,
})
vim.api.nvim_create_user_command("FormatEnable", function()
	vim.b.disable_autoformat = false
	vim.g.disable_autoformat = false
end, {
	desc = "Re-enable autoformat-on-save",
})

-- misc
require("nvim-ts-autotag").setup()
require("gitsigns").setup()

require("oil").setup({
	view_options = {
		show_hidden = true,
	},
})
keymap.set("n", "<leader>e", "<CMD>Oil<CR>", { desc = "File Explorer" })
