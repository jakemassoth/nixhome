{ pkgs }:

''
  lspconfig["elixirls"].setup({
    capabilities = capabilities,
    on_attach = on_attach,
    cmd = { "${pkgs.elixir-ls}/bin/elixir-ls" },
  })

  lspconfig["terraform_lsp"].setup({
    capabilities = capabilities,
    on_attach = on_attach,
    cmd = { "${pkgs.terraform-lsp}/bin/terraform-lsp" },
  })
  local util = require "lspconfig.util"
  local function get_typescript_server_path(root_dir)

    local global_ts = '${pkgs.typescript}/lib'
    local found_ts = ""
    local function check_dir(path)
      found_ts =  util.path.join(path, 'node_modules', 'typescript', 'lib')
      if util.path.exists(found_ts) then
        return path
      end
    end
    if util.search_ancestors(root_dir, check_dir) then
      return found_ts
    else
      return global_ts
    end
  end
  lspconfig["volar"].setup({
      capabilities = capabilities,
      on_attach = on_attach,
      on_new_config = function(new_config, new_root_dir)
        new_config.init_options.typescript.tsdk = get_typescript_server_path(new_root_dir)
      end,
      cmd = {"${pkgs.vue-language-server}/bin/vue-language-server", "--stdio"},
      init_options = {
        vue = {
          hybridMode = false,
        }
      }
  })
  -- configure typescript server with plugin
  lspconfig["ts_ls"].setup({
      cmd = {"${pkgs.typescript-language-server}/bin/typescript-language-server", "--stdio"},
      init_options = {
          plugins = {
            {
              name = '@vue/typescript-plugin',
              location = '${pkgs.vue-language-server}/bin/vue-language-server',
              languages = { 'vue' },
            },
          },
        },
      server = {
          capabilities = capabilities,
          on_attach = on_attach,
      },
  })
  lspconfig["helm_ls"].setup({
      cmd = {'${pkgs.helm-ls}/bin/helm_ls', "serve"},
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
          ["helm-ls"] = {
              yamlls = {
                  path = '${pkgs.yaml-language-server}/bin/yaml-language-server'
              }
          }
      }
  })
  lspconfig["marksman"].setup({
      cmd = {'${pkgs.marksman}/bin/marksman', "server"},
      capabilities = capabilities,
      on_attach = on_attach,
  })
  lspconfig["astro"].setup({
      cmd = {'${
        pkgs.nodePackages."@astrojs/language-server"
      }/bin/astro-ls', "--stdio"},
      capabilities = capabilities,
      on_attach = on_attach,
  })
  lspconfig["bashls"].setup({
      cmd = {'${pkgs.bash-language-server}/bin/bash-language-server', "start"},
      capabilities = capabilities,
      on_attach = on_attach,
  })

  lspconfig["eslint"].setup({
    cmd = { '${pkgs.vscode-langservers-extracted}/bin/vscode-eslint-language-server', '--stdio' },
    capabilities = capabilities,
    on_attach = on_attach,
  })
''
