{ pkgs, lib, ... }:

{
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
          			find_command = { "${pkgs.ripgrep}/bin/rg", "--files", "--hidden", "--glob", "!**/.git/*" },
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
          (import ./lsp-config.nix { inherit pkgs; })
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
      pkgs.vimPlugins.copilot-lua
      {
        plugin = pkgs.vimPlugins.codecompanion-nvim;
        type = "lua";
        config = builtins.readFile ./lua/plugins/codecompanion.lua;
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
