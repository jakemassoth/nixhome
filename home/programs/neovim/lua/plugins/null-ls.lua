local null_ls = require("null-ls")
-- for conciseness
local formatting = null_ls.builtins.formatting     -- to setup formatters
local diagnostics = null_ls.builtins.diagnostics   -- to setup linters
local code_actions = null_ls.builtins.code_actions -- to setup code actions


null_ls.setup({
  sources = {
    formatting.prettier.with({
      extra_filetypes = { "svelte", "astro" },
    }),
    formatting.stylua,
    formatting.nixfmt,
    formatting.black,
    formatting.pint,
    formatting.mix,
    diagnostics.credo,
    diagnostics.actionlint,
    diagnostics.statix,
    code_actions.statix,
    code_actions.shellcheck,
    diagnostics.shellcheck,
  },
})
