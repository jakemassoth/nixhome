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
    vimAlias = true;
    defaultEditor = true;
    extraLuaConfig = builtins.readFile ./lua/config.lua;
    plugins = [
      pkgs.vimPlugins.plenary-nvim
      {
        plugin = pkgs.vimPlugins.snacks-nvim;
        type = "lua";
        config = ''
          require("snacks").setup({
              bigfile = { enabled = true },
              quickfile = { enabled = true },
            })
            vim.keymap.set("n", "<leader>z", function() Snacks.zen() end, { desc = "Toggle Zen Mode" })
            vim.keymap.set("n", "<leader>.", function() Snacks.scratch() end, { desc = "Toggle Scratch Buffer" })
            vim.keymap.set("n", "<leader>S", function() Snacks.scratch.select() end, { desc = "Select Scratch Buffer" })
            vim.keymap.set("n", "<leader>sx", function() Snacks.bufdelete() end, { desc = "Delete Buffer" })
            vim.keymap.set("n", "<leader>cR", function() Snacks.rename.rename_file() end, { desc = "Rename File" })
            vim.keymap.set({ "n", "v" }, "<leader>gB", function() Snacks.gitbrowse() end, { desc = "Git Browse" })
            vim.keymap.set("n", "<leader>gb", function() Snacks.git.blame_line() end, { desc = "Git Blame Line" })
            vim.keymap.set("n", "<leader>gf", function() Snacks.lazygit.log_file() end, { desc = "Lazygit Current File History" })
            vim.keymap.set("n", "<leader>gg", function() Snacks.lazygit() end, { desc = "Lazygit" })
            vim.keymap.set("n", "<leader>gl", function() Snacks.lazygit.log() end, { desc = "Lazygit Log (cwd)" })
        '';
      }

      {
        plugin = pkgs.vimPlugins.mini-nvim;
        type = "lua";
        config = ''
          require("mini.ai").setup()
          require("mini.move").setup()
          require("mini.operators").setup()
          require("mini.pairs").setup()
          require("mini.surround").setup()
          require("mini.statusline").setup()
          require("mini.trailspace").setup()
          require("mini.files").setup()
          require("mini.icons").setup()
          MiniIcons.mock_nvim_web_devicons()
          MiniIcons.tweak_lsp_kind()
        '';
      }

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

      # Telescope + fuzzy finder
      pkgs.vimPlugins.telescope-fzf-native-nvim
      {
        plugin = pkgs.vimPlugins.telescope-nvim;
        type = "lua";
        config = ''
          local actions = require("telescope.actions")
          local telescope = require("telescope")
          local telescopeConfig = require("telescope.config")

          -- Clone the default Telescope configuration
          local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

          -- I want to search in hidden/dot files.
          table.insert(vimgrep_arguments, "--hidden")
          -- I don't want to search in the `.git` directory.
          table.insert(vimgrep_arguments, "--glob")
          table.insert(vimgrep_arguments, "!**/.git/*")
          -- configure telescope
          telescope.setup({
          	-- configure custom mappings
          	defaults = {
          		vimgrep_arguments = vimgrep_arguments,
          	},
          	pickers = {
          		find_files = {
          			-- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
          			find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
          		},
          	},
          })

          telescope.load_extension("fzf")
        '';
      }

      # Snippets + completion
      pkgs.vimPlugins.luasnip
      pkgs.vimPlugins.friendly-snippets

      {
        plugin = pkgs.vimPlugins.blink-cmp;
        type = "lua";
        config = ''
          require("blink.cmp").setup({
          	keymap = { preset = "default" },
          	appearance = {
          		use_nvim_cmp_as_default = true,
          		nerd_font_variant = "mono",
          	},
          	sources = {
          		default = { "lsp", "path", "snippets", "buffer", "codecompanion" },
          	},
          	signature = { enabled = true },
          })

        '';
      }
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
          ''
        ];
      }
      {
        plugin = pkgs.vimPlugins.null-ls-nvim;
        type = "lua";
        config = builtins.readFile ./lua/plugins/null-ls.lua;
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
      pkgs.vimPlugins.vim-helm
      {
        plugin = pkgs.vimPlugins.codecompanion-nvim;
        type = "lua";
        config = ''
          require("codecompanion").setup({
          	adapters = {
          		copilot = function()
          			return require("codecompanion.adapters").extend("copilot", {
          				schema = {
          					model = {
          						default = "claude-3.5-sonnet",
          					},
          				},
          			})
          		end,
          	},
          	strategies = {
          		chat = {
          			adapter = "copilot",
          		},
          		inline = {
          			adapter = "copilot",
          		},
          	},
          	slash_commands = {
          		["file"] = {
          			opts = {
          				provider = "telescope",
          			},
          		},
          	},
          	display = {
          		action_palette = { provider = "telescope" },
          	},
          })
          vim.keymap.set({ "n", "v" }, "<leader>c", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
          vim.keymap.set({ "n", "v" }, "<leader><CR>", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
          vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

          -- Expand 'cc' into 'CodeCompanion' in the command line
          vim.cmd([[cab cc CodeCompanion]])
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
      pkgs.vscode-langservers-extracted
      pkgs.svelte-language-server
      pkgs.sumneko-lua-language-server
      pkgs.tailwindcss-language-server
      pkgs.nodePackages.intelephense

      # linters/formatters
      pkgs.statix
      pkgs.nixfmt-classic
      pkgs.actionlint
      pkgs.stylua
      pkgs.nodePackages.prettier
      pkgs.gofumpt
      pkgs.shellcheck
      pkgs.shfmt
    ];
    extraLuaPackages = ps: [ ps.middleclass ];
  };
}
