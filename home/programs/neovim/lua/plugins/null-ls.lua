local null_ls = require("null-ls")
-- for conciseness
local formatting = null_ls.builtins.formatting   -- to setup formatters
local diagnostics = null_ls.builtins.diagnostics -- to setup linters


null_ls.setup({
  sources = {
    formatting.prettier.with({
      extra_filetypes = { "svelte", "astro" },
    }),
    formatting.pint,
    diagnostics.credo,
  },
})
