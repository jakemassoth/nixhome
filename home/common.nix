{ config, pkgs, lib, ... }:

{
  imports = [ ./programs/neovim/neovim.nix ];
  fonts.fontconfig.enable = true;
  home.packages = [
    (pkgs.nerdfonts.override { fonts = [ "Hack" ]; })
    pkgs.eza
    pkgs.ripgrep
    pkgs.yarn
    pkgs.nodejs_18
    pkgs.devbox
  ];
  home.stateVersion = "24.05";

  programs.tmux = {
    enable = true;

    keyMode = "vi";
    mouse = true;
    prefix = "C-a";

    terminal = "screen-256color";

    shell = "${pkgs.zsh}/bin/zsh";
    extraConfig = ''
      unbind %
      bind | split-window -h

      unbind '"'
      bind - split-window -v


      bind-key -T copy-mode-vi 'v' send -X begin-selection # start selecting text with "v"
      bind-key -T copy-mode-vi 'y' send -X copy-selection # copy text with "y"

      unbind -T copy-mode-vi MouseDragEnd1Pane # don't exit copy mode after dragging with mouse
      set-option -sa terminal-overrides ',xterm-256color:RGB'
    '';
    plugins = [
      {
        plugin = pkgs.tmuxPlugins.continuum;
        extraConfig = "set -g @continuum-restore 'on'";
      }
      {
        plugin = pkgs.tmuxPlugins.resurrect;
        extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      }
      pkgs.tmuxPlugins.vim-tmux-navigator
      pkgs.tmuxPlugins.sensible
      {
        plugin = pkgs.tmuxPlugins.power-theme;
        extraConfig = "set -g @tmux_power_theme '#89b4fa'";
      }
    ];
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      tmux = "tmux -f ~/.config/tmux/tmux.conf";
      ls = "eza";
      hms =
        "export NIXPKGS_ALLOW_UNFREE=1 && home-manager -f ~/.config/nixpkgs/$HOST/home.nix switch";
      access = "cd ~/development/storyteq/access";
      api = "cd ~/development/storyteq/storyteq-api";
      platform = "cd ~/development/storyteq/storyteq-platform";
    };
    enableCompletion = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;
    autocd = true;
    initExtra = ''
      export PATH="/Users/jakemassoth/.local/bin:$PATH"
      export NVM_DIR="${config.home.homeDirectory}/.nvm"
      [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
        # The next line updates PATH for the Google Cloud SDK.
        if [ -f '~/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '~/Downloads/google-cloud-sdk/path.zsh.inc'; fi

        # The next line enables shell command completion for gcloud.
        if [ -f '~/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '~/Downloads/google-cloud-sdk/completion.zsh.inc'; fi
    '';
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        file = "p10k.zsh";
        name = "p10k-config";
        src = lib.cleanSource ../p10k-config;
      }
    ];
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
    };
  };

  programs.git = {
    enable = true;
    userEmail = "jakemassoth@storyteq.com";
    userName = "Jake Massoth";
    aliases = {
      s = "status";
      c = "commit -m";
      ca = "commit -am";
      co = "checkout";
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
