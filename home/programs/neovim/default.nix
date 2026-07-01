{
  pkgs,
  lib,
  ...
}: let
  angular-language-server = pkgs.callPackage ./angular-language-server.nix {};
in {
  # set some ripgrep config that will be local to neovim
  home.file.".config/ripgrep/nvim-config".text = ''
    --hidden
    --follow
    --smart-case
    --max-columns=150
    --glob=!.git/*
    --glob=!node_modules/*
    --glob=!target/*
    --glob=!build/*
  '';
  programs.neovim = {
    enable = true;
    vimAlias = true;
    defaultEditor = true;
    withRuby = false;
    withPython3 = false;
    initLua = lib.strings.concatStrings [
      # ''
      #   local vue_language_server_path = '${pkgs.vue-language-server}/lib/language-tools/packages/language-server'
      # ''
      (builtins.readFile ./lua/config.lua)
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
      rose-pine
    ];
    extraPackages = with pkgs; [
      fd
      ripgrep

      # lsps
      nixd
      gopls
      pyright
      svelte-language-server
      lua-language-server
      tailwindcss-language-server
      intelephense
      elixir-ls
      terraform-ls
      typescript-language-server
      helm-ls
      marksman
      astro-language-server
      bash-language-server
      vscode-langservers-extracted
      rust-analyzer
      tinymist
      templ
      angular-language-server
      prisma-language-server

      # linters/formatters
      shellcheck
      stylua
      rustfmt
      alejandra
    ];
  };
}
