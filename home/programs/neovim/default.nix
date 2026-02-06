{
  pkgs,
  lib,
  ...
}: let
in {
  stylix.targets.neovim.enable = false;
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
    initLua = lib.strings.concatStrings [
      ''
        local vue_language_server_path = '${pkgs.vue-language-server}/lib/language-tools/packages/language-server'
      ''
      (builtins.readFile ./lua/config.lua)
    ];
    plugins = with pkgs.vimPlugins; [
      mini-nvim

      nvim-treesitter-legacy.withAllGrammars
      luasnip
      friendly-snippets
      blink-cmp
      oil-nvim
      nvim-ts-autotag

      nvim-lspconfig
      vim-helm
      conform-nvim
      catppuccin-nvim
      llama-vim
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
      tinymist
      templ
      angular-language-server

      # linters/formatters
      nodePackages.prettier
      shellcheck
      stylua
      rustfmt
      alejandra
    ];
  };

  # Disable stylix for neovim since we manage it ourselves
  # stylix.targets.neovim.plugin = "base16-nvim";
}
