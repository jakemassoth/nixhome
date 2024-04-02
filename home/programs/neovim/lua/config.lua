-- KEYMAPS
vim.g.mapleader = " "

local keymap = vim.keymap

keymap.set("n", "x", '"_x"') -- don't copy into the register when deleting with x

keymap.set("n", "<leader>+", "<C-a>")
keymap.set("n", "<leader>-", "<C-x>")

-- splitting windows
keymap.set("n", "<leader>sv", "<C-w>v") -- split vertially
keymap.set("n", "<leader>sh", "<C-w>s") -- split horizontally
keymap.set("n", "<leader>se", "<C-w>=") -- make windows equal width
keymap.set("n", "<leader>sx", ":bd<CR>")

-- vim-maximizer
keymap.set("n", "<leader>sm", ":MaximizerToggle<CR>") -- toggle maximising a split window

-- nvim-tree
keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")

-- telescope
keymap.set("n", "<leader>ff", "<cmd>Telescope git_files<cr>") -- find files within current working directory, respects .gitignore
keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>") -- find string in current working directory as you type
keymap.set("n", "<leader>fc", "<cmd>Telescope lsp_document_symbols<cr>") -- find string under cursor in current working directory
keymap.set("n", "<leader>fd", "<cmd>Telescope diagnostics<cr>") -- find string under cursor in current working directory
keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>") -- list open buffers in current neovim instance
keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>") -- list available help tags

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
opt.tabstop = 4
opt.shiftwidth = 4
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

-- backspace
opt.backspace = "indent,eol,start"

-- clipboard
opt.clipboard:append("unnamedplus")

-- split windows
opt.splitright = true
opt.splitbelow = true
