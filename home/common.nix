{ pkgs, ... }:

{
  fonts.fontconfig.enable = true;
  home.packages = [
    (pkgs.nerdfonts.override { fonts = [ "Hack" ]; })
    pkgs.eza
    pkgs.ripgrep
    pkgs.yarn
    pkgs.nodejs_18
    pkgs.devbox
    pkgs.google-cloud-sdk
  ];

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

  programs.bat.enable = true;
  programs.fzf.enable = true;
  programs.jq.enable = true;
  programs.htop.enable = true;

  programs.zsh = {
    enable = true;
    shellAliases = {
      tmux = "tmux -f ~/.config/tmux/tmux.conf";
      ls = "eza";
      hms = "home-manager switch";
      access = "cd ~/development/storyteq/access";
      api = "cd ~/development/storyteq/storyteq-api";
      platform = "cd ~/development/storyteq/storyteq-platform";
      cd = "z";
    };
    enableCompletion = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;
    autocd = true;
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
      kick = "commit --allow-empty -m 'noop'";
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.starship = {
    enable = true;
    settings = {
      username = {
        style_user = "blue bold";
        style_root = "red bold";
        format = "[$user]($style) ";
        disabled = false;
        show_always = true;
      };
      hostname = {
        ssh_only = false;
        ssh_symbol = "🌐 ";
        format = "on [$hostname](bold red) ";
        trim_at = ".local";
        disabled = false;
      };
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
