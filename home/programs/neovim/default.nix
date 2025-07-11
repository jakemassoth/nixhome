{
  pkgs,
  lib,
  ...
}: {
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
        config = builtins.readFile ./lua/plugins/snacks.lua;
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
          		default = { "lsp", "path", "snippets", "buffer"},
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
          (import ./lsp-config.nix {inherit pkgs;})
        ];
      }
      {
        plugin = pkgs.vimPlugins.conform-nvim;
        type = "lua";
        config = builtins.readFile ./lua/plugins/conform.lua;
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
      pkgs.vimPlugins.vim-helm
      {
        plugin = pkgs.vimPlugins.oil-nvim;
        type = "lua";
        config = ''
          require('oil').setup({
            view_options = {
              show_hidden = true,
            }
          })
          vim.keymap.set("n", "<leader>e", "<CMD>Oil<CR>", { desc = "File Explorer" })
        '';
      }
    ];
    extraPackages = [
      pkgs.fd
      pkgs.ripgrep

      pkgs.nodejs_22

      # lsps
      pkgs.nil
      pkgs.gopls
      pkgs.pyright

      pkgs.svelte-language-server
      pkgs.sumneko-lua-language-server
      pkgs.tailwindcss-language-server
      pkgs.nodePackages.intelephense

      # linters/formatters
      pkgs.nodePackages.prettier
      pkgs.shellcheck
    ];
    extraLuaPackages = ps: [ps.middleclass];
  };
}
