-- KEYMAPS
vim.g.mapleader = " "

vim.cmd.colorscheme("catppuccin-mocha")

local keymap = vim.keymap

keymap.set("n", "x", '"_x"') -- don't copy into the register when deleting with x

keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true })
keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true })

-- greatest remap ever
keymap.set("x", "<leader>p", [["_dP]])

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
	"tinymist",
	"templ",
	"angularls",
})

-- This is set by nix, we concat the two files together
-- local vue_language_server_path = '/path/to/@vue/language-server'
local tsserver_filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" }
local vue_plugin = {
	name = "@vue/typescript-plugin",
	location = vue_language_server_path,
	languages = { "vue" },
	configNamespace = "typescript",
}

local ts_ls_config = {
	init_options = {
		plugins = {
			vue_plugin,
		},
	},
	filetypes = tsserver_filetypes,
}

vim.lsp.config("ts_ls", ts_ls_config)

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
				version = "LuaJIT",
				path = {
					"lua/?.lua",
					"lua/?/init.lua",
				},
			},
			workspace = {
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME,
				},
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

require("mini.diff").setup({
	view = {
		style = "sign",
	},
})
local MiniIcons = require("mini.icons")
local MiniPick = require("mini.pick")

MiniIcons.setup()
MiniIcons.mock_nvim_web_devicons()
MiniIcons.tweak_lsp_kind()

vim.env.RIPGREP_CONFIG_PATH = vim.fn.expand("~/.config/ripgrep/nvim-config")
MiniPick.setup()
keymap.set("n", "<leader><space>", function()
	MiniPick.builtin.files({ tool = "rg" })
end)
keymap.set("n", "<leader>/", function()
	MiniPick.builtin.grep_live({ tool = "rg" })
end)
keymap.set("n", "<leader>fb", function()
	MiniPick.builtin.buffers()
end)
keymap.set("n", "<leader>fh", function()
	MiniPick.builtin.help({ default_split = "tab" })
end)
keymap.set("n", "<leader>fr", "<CMD>Pick resume<CR>")

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
		templ = { "templ", "injected" },
		htmlangular = { "prettier" },
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

require("oil").setup({
	view_options = {
		show_hidden = true,
	},
})
keymap.set("n", "<leader>e", "<CMD>Oil<CR>", { desc = "File Explorer" })

vim.g.llama_config = {
	show_info = false,
}

-- llama-server lifecycle + log buffer
local llama_job_id = nil
local llama_bufnr = nil

local function ensure_llama_buffer()
	if llama_bufnr and vim.api.nvim_buf_is_valid(llama_bufnr) then
		return llama_bufnr
	end
	llama_bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_name(llama_bufnr, "Llama Logs")
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = llama_bufnr })
	vim.api.nvim_set_option_value("swapfile", false, { buf = llama_bufnr })
	vim.api.nvim_set_option_value("bufhidden", "hide", { buf = llama_bufnr })
	return llama_bufnr
end

local function append_llama_log(lines)
	if not lines or #lines == 0 then
		return
	end
	local buf = ensure_llama_buffer()
	-- jobstart often sends a trailing empty line; keep logs tidy
	if #lines == 1 and lines[1] == "" then
		return
	end
	vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
end

local function stop_llama_server()
	if llama_job_id then
		pcall(vim.fn.jobstop, llama_job_id)
		llama_job_id = nil
	end
end

local function start_llama_server()
	if llama_job_id then
		return
	end
	ensure_llama_buffer()
	llama_job_id = vim.fn.jobstart({ "llama-server", "--fim-qwen-7b-default" }, {
		stdout_buffered = false,
		stderr_buffered = false,
		on_stdout = function(_, data, _)
			append_llama_log(data)
		end,
		on_stderr = function(_, data, _)
			append_llama_log(data)
		end,
		on_exit = function(_, code, _)
			append_llama_log({ "", "llama-server exited with code " .. tostring(code) })
			llama_job_id = nil
		end,
	})
end

vim.api.nvim_create_user_command("LlamaLogs", function()
	local buf = ensure_llama_buffer()
	vim.cmd("botright 12split")
	vim.api.nvim_win_set_buf(0, buf)
	vim.api.nvim_set_option_value("wrap", false, { win = 0 })
end, { desc = "Open llama-server logs" })

vim.api.nvim_create_user_command("LlamaRestart", function()
	stop_llama_server()
	start_llama_server()
end, { desc = "Restart llama-server" })

vim.api.nvim_create_user_command("LlamaStop", function()
	stop_llama_server()
end, { desc = "Stop llama-server" })

vim.api.nvim_create_autocmd("VimLeavePre", {
	callback = function()
		stop_llama_server()
	end,
})
