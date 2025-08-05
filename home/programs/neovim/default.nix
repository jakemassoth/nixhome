{
  pkgs,
  lib,
  ...
}: {
  programs.neovim = {
    enable = true;
    vimAlias = true;
    defaultEditor = true;
    extraLuaConfig = lib.strings.concatStrings [
      (builtins.readFile ./lua/config.lua)
      # this requires an absolute path, so we need to give it the real path in nix-store
      ''
        vim.lsp.config('ts_ls', {
          init_options = {
            plugins = {
              {
                name = "@vue/typescript-plugin",
                location = '${pkgs.vue-language-server}/lib/node_modules/@vue/language-server',
                languages = { "javascript", "typescript", "vue" },
              },
            },
          },
          filetypes = {
            "javascript",
            "typescript",
            "vue",
          },
        })

      ''
    ];
    plugins = with pkgs.vimPlugins; [
      mini-nvim

      nvim-treesitter.withAllGrammars
      luasnip
      friendly-snippets
      blink-cmp
      oil-nvim
      nvim-ts-autotag

      nvim-lspconfig
      vim-helm
      conform-nvim
    ];
    extraPackages = with pkgs; [
      fd
      ripgrep

      # lsps
      nixd
      gopls
      pyright
      svelte-language-server
      sumneko-lua-language-server
      tailwindcss-language-server
      nodePackages.intelephense
      elixir-ls
      terraform-ls
      vue-language-server
      typescript-language-server
      helm-ls
      marksman
      nodePackages."@astrojs/language-server"
      bash-language-server
      vscode-langservers-extracted
      rust-analyzer

      # linters/formatters
      nodePackages.prettier
      shellcheck
      stylua
      rustfmt
      alejandra
    ];
  };
}
