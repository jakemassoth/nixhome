local setup, nvimtree = pcall(require, "nvim-tree")
if not setup then
	return
end

-- recommended settings from nvim-tree
vim.g.loaded = 1
vim.g.loaded_netrwPlugin = 1

nvimtree.setup({
	git = {
		ignore = false,
	},
	actions = {
		open_file = {
			window_picker = {
				enable = false,
			},
		},
	},
})
