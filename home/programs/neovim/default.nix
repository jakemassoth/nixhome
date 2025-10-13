{
  pkgs,
  lib,
  ...
}: {
  # stylix.targets.neovim.plugin = "base16-nvim";

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
    extraLuaConfig = lib.strings.concatStrings [
      # this requires an absolute path, so we need to give it the real path in nix-store
      ''
        local vue_language_server_path = '${pkgs.vue-language-server}/lib/language-tools/packages/language-server'
      ''
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
      catppuccin-nvim
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
      tinymist

      # linters/formatters
      nodePackages.prettier
      shellcheck
      stylua
      rustfmt
      alejandra
    ];
  };

  # Disable stylix for neovim since we manage it ourselves
  stylix.targets.neovim.enable = false;
}
