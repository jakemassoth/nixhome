-- KEYMAPS
vim.g.mapleader = " "

local keymap = vim.keymap

keymap.set("n", "x", '"_x"') -- don't copy into the register when deleting with x

keymap.set("n", "<leader>+", "<C-a>")
keymap.set("n", "<leader>-", "<C-x>")

-- splitting windows
keymap.set("n", "<leader>sv", "<C-w>v") -- split vertially
keymap.set("n", "<leader>sh", "<C-w>s") -- split horizontally

-- telescope
local telescope = require("telescope.builtin")
keymap.set("n", "<leader>ff", telescope.find_files) -- find files within current working directory, respects .gitignore

keymap.set("n", "<leader>ff", telescope.find_files, { desc = "Telescope find files" })
keymap.set("n", "<leader>fs", telescope.live_grep, { desc = "Telescope live grep" })
keymap.set("n", "<leader>fb", telescope.buffers, { desc = "Telescope buffers" })
keymap.set("n", "<leader>fh", telescope.help_tags, { desc = "Telescope help tags" })
keymap.set("n", "<leader>fc", telescope.lsp_document_symbols, { desc = "Telescope LSP symbols" })

keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true })
keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true })

-- greatest remap ever
keymap.set("x", "<leader>p", [["_dP]])

-- save file(s) on leader + wf
keymap.set("n", "<leader>wf", "<cmd>w<CR>")
keymap.set("n", "<leader>wa", "<cmd>wa<CR>")

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
