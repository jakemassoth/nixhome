local lspconfig = require("lspconfig")

local keymap = vim.keymap -- for conciseness

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

-- enable keybinds only for when lsp server available
local on_attach = function(current_client, bufnr)
  -- keybind options
  local opts = { noremap = true, silent = true, buffer = bufnr }

  -- set keybinds
  keymap.set("n", "gd", vim.lsp.buf.definition, opts)          -- got to declaration
  keymap.set("n", "gi", vim.lsp.buf.implementation, opts)      -- go to implementation
  keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions
  keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)      -- smart rename
  keymap.set("n", "gh", vim.lsp.buf.hover, opts)               -- show documentation for what is under cursor
  keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

  -- tsserver breaks the prettier formatting
  if current_client.name == "tsserver" then
    current_client.server_capabilities.documentFormattingProvider = false
  end

  vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })

  vim.api.nvim_create_autocmd("BufWritePre", {
    group = augroup,
    buffer = bufnr,
    callback = function()
      local lsp_clients = vim.lsp.get_clients({ bufnr = bufnr })
      local primary_lsp_formatter_found = false

      -- Use the LSP if available
      for _, lsp_client in ipairs(lsp_clients) do
        if lsp_client.name ~= "null-ls" and lsp_client.supports_method("textDocument/formatting", bufnr) then
          primary_lsp_formatter_found = true
          break
        end
      end

      vim.lsp.buf.format({
        bufnr = bufnr,
        filter = function(client)
          -- if the primary_lsp_formatter_found, then we wanna use the client itself. if not, then we want to use the null ls one
          return (client.name ~= "null-ls") == primary_lsp_formatter_found
        end,
      })
    end,
  })
end

-- used to enable autocompletion (assign to every lsp server config)
local capabilities = require("blink.cmp").get_lsp_capabilities()

-- configure html server
lspconfig["html"].setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

-- configure css server
lspconfig["cssls"].setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

-- configure nix server
lspconfig["nil_ls"].setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

lspconfig["jsonls"].setup({
  capabilities = capabilities,
  on_attach = on_attach,
  filetypes = { "json", "jsonc" },
  settings = {
    json = {
      -- Schemas https://www.schemastore.org
      schemas = {
        {
          fileMatch = { "package.json" },
          url = "https://json.schemastore.org/package.json",
        },
        {
          fileMatch = { "tsconfig*.json" },
          url = "https://json.schemastore.org/tsconfig.json",
        },
      },
    },
  },
})

lspconfig["gopls"].setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

lspconfig["svelte"].setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

lspconfig["pyright"].setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

lspconfig["tailwindcss"].setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

lspconfig["intelephense"].setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

lspconfig["graphql"].setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

-- configure lua server (with special settings)
lspconfig["lua_ls"].setup({
  capabilities = capabilities,
  on_attach = on_attach,
  settings = { -- custom settings for lua
    Lua = {
      -- make the language server recognize "vim" global
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        -- make language server aware of runtime files
        library = {
          [vim.fn.expand("$VIMRUNTIME/lua")] = true,
          [vim.fn.stdpath("config") .. "/lua"] = true,
        },
      },
    },
  },
})
