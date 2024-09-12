{ pkgs, lib, ... }:

let
  fromGitHub = rev: repo:
    pkgs.vimUtils.buildVimPlugin {
      pname = "${lib.strings.sanitizeDerivationName repo}";
      version = rev;
      src = builtins.fetchGit {
        url = "https://github.com/${repo}.git";
        inherit rev;
      };
    };

in {
  programs.neovim = {
    enable = true;
    catppuccin.enable = true;
    vimAlias = true;
    defaultEditor = true;
    extraLuaConfig = builtins.readFile ./lua/config.lua;
    plugins = [
      pkgs.vimPlugins.plenary-nvim

      {
        plugin = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
        type = "lua";
        config = ''
          require("nvim-treesitter.configs").setup({
          	highlight = {
          		enable = true,
          	},
          	indent = { enable = true },
          })
        '';
      }

      (fromGitHub "21ce711396b1d836a75781d65f34241f14161f94"
        "nkrkv/nvim-treesitter-rescript")
      pkgs.vimPlugins.vim-tmux-navigator
      pkgs.vimPlugins.vim-surround

      {
        plugin = pkgs.vimPlugins.comment-nvim;
        type = "lua";
        config = ''
          require("Comment").setup()
        '';
      }

      {
        plugin = pkgs.vimPlugins.nvim-tree-lua;
        type = "lua";
        config = ''
          vim.g.loaded = 1
          vim.g.loaded_netrwPlugin = 1

          require("nvim-tree").setup({
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
        '';
      }

      pkgs.vimPlugins.nvim-web-devicons

      {
        plugin = pkgs.vimPlugins.lualine-nvim;
        type = "lua";
        config = ''
          require("lualine").setup()
        '';
      }

      # Telescope + fuzzy finder
      pkgs.vimPlugins.telescope-fzf-native-nvim
      {
        plugin = pkgs.vimPlugins.telescope-nvim;
        type = "lua";
        config = ''
          local actions = require("telescope.actions")
          local telescope = require("telescope")
          -- configure telescope
          telescope.setup({
          	-- configure custom mappings
          	defaults = {
          		mappings = {
          			i = {
          				["<C-k>"] = actions.move_selection_previous, -- move to prev result
          				["<C-j>"] = actions.move_selection_next, -- move to next result
          				["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist, -- send selected to quickfixlist
          			},
          		},
          	},
          })

          telescope.load_extension("fzf")
        '';
      }

      # Snippets + completion
      pkgs.vimPlugins.luasnip
      pkgs.vimPlugins.lspkind-nvim
      {
        plugin = pkgs.vimPlugins.nvim-cmp;
        type = "lua";
        config = builtins.readFile ./lua/plugins/nvim-cmp.lua;
      }
      pkgs.vimPlugins.cmp-buffer
      pkgs.vimPlugins.cmp-path
      pkgs.vimPlugins.cmp_luasnip
      pkgs.vimPlugins.friendly-snippets

      # LSP
      pkgs.vimPlugins.cmp-nvim-lsp
      {
        plugin = pkgs.vimPlugins.nvim-lspconfig;
        type = "lua";
        config = lib.strings.concatStrings [
          (builtins.readFile ./lua/plugins/lspconfig.lua)
          ''
            lspconfig["rescriptls"].setup({
            	capabilities = capabilities,
            	on_attach = on_attach,
            	cmd = { "node", "${
               fromGitHub "2065f4e1d319ffd4ff7046879f270ebbadda873e"
               "rescript-lang/vim-rescript"
             }/server/out/server.js", "--stdio" },
            })
          ''
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
            lspconfig["tsserver"].setup({
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
            lspconfig["stylelint_lsp"].setup({
                cmd = {'${pkgs.stylelint-lsp}/bin/stylelint-lsp', "--stdio"},
                capabilities = capabilities,
                on_attach = on_attach,
            })
          ''
        ];
      }
      {
        plugin = pkgs.vimPlugins.lspsaga-nvim;
        type = "lua";
        config = ''
          require("lspsaga").setup()
        '';
      }
      {
        plugin = pkgs.vimPlugins.null-ls-nvim;
        type = "lua";
        config = builtins.readFile ./lua/plugins/null-ls.lua;
      }
      {
        plugin = pkgs.vimPlugins.nvim-autopairs;
        type = "lua";
        config = ''
          require("nvim-autopairs").setup({
          	check_ts = true,
          	ts_config = {
          		lua = { "string" },
          		javascript = { "template_string" },
          	},
          })

          require("cmp").event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())
        '';
      }
      {

        plugin = pkgs.vimPlugins.nvim-ts-autotag;
        type = "lua";
        config = ''
          require('nvim-ts-autotag').setup()
        '';
      }
      {
        plugin = pkgs.vimPlugins.gitsigns-nvim;
        type = "lua";
        config = ''
          require("gitsigns").setup()
        '';
      }
      {
        plugin = pkgs.vimPlugins.windows-nvim;
        type = "lua";
        config = ''
          require('windows').setup()

          vim.keymap.set('n', '<leader>sm', '<Cmd>WindowsMaximize<CR>')
          vim.keymap.set('n', '<leader>se', '<Cmd>WindowsEqualize<CR>')
        '';
      }
      {
        plugin = pkgs.vimPlugins.vim-fugitive;
        type = "lua";
        config = ''
          vim.keymap.set('n', '<leader>gs', '<Cmd>Git<CR>')
          vim.keymap.set('n', '<leader>gB', '<Cmd>GBrowse<CR>')
          vim.keymap.set('v', '<leader>gB', "<Cmd>'<,'>GBrowse<CR>")
          vim.keymap.set('n', '<leader>gb', '<Cmd>Git blame<CR>')
          vim.keymap.set('n', '<leader>gp', '<Cmd>Git pull<CR>')
          vim.keymap.set('n', '<leader>gP', '<Cmd>Git push<CR>')
        '';
      }
      pkgs.vimPlugins.fugitive-gitlab-vim
      pkgs.vimPlugins.vim-rhubarb
      pkgs.vimPlugins.vim-helm
      {
        plugin = pkgs.vimPlugins.copilot-lua;
        type = "lua";
        config = ''
          require("copilot").setup({
            suggestion = { enabled = false },
            panel = { enabled = false },
          })
        '';
      }
      {
        plugin = pkgs.vimPlugins.copilot-cmp;
        type = "lua";
        config = ''
          require("copilot_cmp").setup()
        '';
      }
    ];
    extraPackages = [
      pkgs.fd
      pkgs.ripgrep

      # lsps
      pkgs.nil
      pkgs.gopls
      pkgs.pyright
      pkgs.nodejs
      pkgs.typescript
      pkgs.typescript-language-server
      pkgs.vscode-langservers-extracted
      pkgs.svelte-language-server
      pkgs.vue-language-server
      pkgs.sumneko-lua-language-server
      pkgs.tailwindcss-language-server
      pkgs.nodePackages.intelephense
      pkgs.nodePackages.graphql-language-service-cli

      # linters/formatters
      pkgs.statix
      pkgs.nixfmt-classic
      pkgs.actionlint
      pkgs.stylua
      pkgs.nodePackages.prettier
      pkgs.gofumpt
    ];
    extraLuaPackages = ps: [ ps.middleclass ];
  };
}
