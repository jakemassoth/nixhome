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
      pkgs.vimPlugins.dressing-nvim
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
          		mappings = {
          			i = {
          				["<C-k>"] = actions.move_selection_previous, -- move to prev result
          				["<C-j>"] = actions.move_selection_next, -- move to next result
          				["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist, -- send selected to quickfixlist
          			},
          		},
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
            lspconfig["stylelint_lsp"].setup({
                cmd = {'${pkgs.stylelint-lsp}/bin/stylelint-lsp', "--stdio"},
                capabilities = capabilities,
                on_attach = on_attach,
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
      pkgs.vimPlugins.nui-nvim
      {

        plugin = pkgs.vimPlugins.img-clip-nvim;
        type = "lua";
        config = ''
          require("img-clip").setup({
          	opts = {
          		-- recommended settings
          		default = {
          			embed_image_as_base64 = false,
          			prompt_for_file_name = false,
          			drag_and_drop = {
          				insert_mode = true,
          			},
          		},
          	},
          })
        '';
      }
      {
        plugin = pkgs.vimPlugins.render-markdown-nvim;
        type = "lua";
        config = ''
          require("render-markdown").setup({
          	opts = {
          		file_types = { "markdown", "Avante" },
          	},
          })
        '';
      }
      {
        plugin = pkgs.vimPlugins.avante-nvim;
        type = "lua";
        config = ''
          require("avante_lib").load()
          require("avante").setup({
          	---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
          	provider = "claude", -- Recommend using Claude
          	auto_suggestions_provider = "claude", -- Since auto-suggestions are a high-frequency operation and therefore expensive, it is recommended to specify an inexpensive provider or even a free provider: copilot
          	claude = {
          		endpoint = "https://api.anthropic.com",
          		model = "claude-3-5-sonnet-20241022",
          		temperature = 0,
          		max_tokens = 4096,
          	},
          	---Specify the special dual_boost mode
          	---1. enabled: Whether to enable dual_boost mode. Default to false.
          	---2. first_provider: The first provider to generate response. Default to "openai".
          	---3. second_provider: The second provider to generate response. Default to "claude".
          	---4. prompt: The prompt to generate response based on the two reference outputs.
          	---5. timeout: Timeout in milliseconds. Default to 60000.
          	---How it works:
          	--- When dual_boost is enabled, avante will generate two responses from the first_provider and second_provider respectively. Then use the response from the first_provider as provider1_output and the response from the second_provider as provider2_output. Finally, avante will generate a response based on the prompt and the two reference outputs, with the default Provider as normal.
          	---Note: This is an experimental feature and may not work as expected.
          	dual_boost = {
          		enabled = false,
          		first_provider = "openai",
          		second_provider = "claude",
          		prompt = "Based on the two reference outputs below, generate a response that incorporates elements from both but reflects your own judgment and unique perspective. Do not provide any explanation, just give the response directly. Reference Output 1: [{{provider1_output}}], Reference Output 2: [{{provider2_output}}]",
          		timeout = 60000, -- Timeout in milliseconds
          	},
          	behaviour = {
          		auto_suggestions = false, -- Experimental stage
          		auto_set_highlight_group = true,
          		auto_set_keymaps = true,
          		auto_apply_diff_after_generation = false,
          		support_paste_from_clipboard = false,
          		minimize_diff = true, -- Whether to remove unchanged lines when applying a code block
          	},
          	mappings = {
          		--- @class AvanteConflictMappings
          		diff = {
          			ours = "co",
          			theirs = "ct",
          			all_theirs = "ca",
          			both = "cb",
          			cursor = "cc",
          			next = "]x",
          			prev = "[x",
          		},
          		suggestion = {
          			accept = "<M-l>",
          			next = "<M-]>",
          			prev = "<M-[>",
          			dismiss = "<C-]>",
          		},
          		jump = {
          			next = "]]",
          			prev = "[[",
          		},
          		submit = {
          			normal = "<CR>",
          			insert = "<C-s>",
          		},
          		sidebar = {
          			apply_all = "A",
          			apply_cursor = "a",
          			switch_windows = "<Tab>",
          			reverse_switch_windows = "<S-Tab>",
          		},
          	},
          	hints = { enabled = true },
          	windows = {
          		---@type "right" | "left" | "top" | "bottom"
          		position = "right", -- the position of the sidebar
          		wrap = true, -- similar to vim.o.wrap
          		width = 30, -- default % based on available width
          		sidebar_header = {
          			enabled = true, -- true, false to enable/disable the header
          			align = "center", -- left, center, right for title
          			rounded = true,
          		},
          		input = {
          			prefix = "> ",
          			height = 8, -- Height of the input window in vertical layout
          		},
          		edit = {
          			border = "rounded",
          			start_insert = true, -- Start insert mode when opening the edit window
          		},
          		ask = {
          			floating = false, -- Open the 'AvanteAsk' prompt in a floating window
          			start_insert = true, -- Start insert mode when opening the ask window
          			border = "rounded",
          			---@type "ours" | "theirs"
          			focus_on_apply = "ours", -- which diff to focus after applying
          		},
          	},
          	highlights = {
          		---@type AvanteConflictHighlights
          		diff = {
          			current = "DiffText",
          			incoming = "DiffAdd",
          		},
          	},
          	--- @class AvanteConflictUserConfig
          	diff = {
          		autojump = true,
          		---@type string | fun(): any
          		list_opener = "copen",
          		--- Override the 'timeoutlen' setting while hovering over a diff (see :help timeoutlen).
          		--- Helps to avoid entering operator-pending mode with diff mappings starting with `c`.
          		--- Disable by setting to -1.
          		override_timeoutlen = 500,
          	},
          })
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
      pkgs.nodePackages.graphql-language-service-cli

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
