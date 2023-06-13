{ config, pkgs, lib, ... }:

# TODO vim-maximizer
# TODO typescript

{
  programs.neovim = {
    enable = true;
    viAlias = true;
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
          	autotag = { enable = true },
          })
        '';
      }

      {
        plugin = pkgs.vimPlugins.catppuccin-nvim;
        type = "lua";
        config = ''
          vim.cmd("colorscheme catppuccin")
        '';
      }

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
        config = builtins.readFile ./lua/plugins/lspconfig.lua;
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
      pkgs.vimPlugins.nvim-ts-autotag
      {
        plugin = pkgs.vimPlugins.gitsigns-nvim;
        type = "lua";
        config = ''
          require("gitsigns").setup()
        '';
      }

    ];
    extraPackages = [
      pkgs.fd
      pkgs.ripgrep
      # lsps
      pkgs.rnix-lsp

      pkgs.gopls

      pkgs.pyright

      pkgs.nodejs
      pkgs.nodePackages.typescript
      pkgs.nodePackages.typescript-language-server
      pkgs.nodePackages.vscode-langservers-extracted
      pkgs.nodePackages.svelte-language-server

      pkgs.nodePackages.yaml-language-server

      pkgs.sumneko-lua-language-server

      # linters/formatters
      pkgs.statix
      pkgs.nixfmt
      pkgs.actionlint
      pkgs.stylua
      pkgs.nodePackages.prettier
      pkgs.gofumpt
    ];
  };
}
