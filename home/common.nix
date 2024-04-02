{ pkgs, ... }:

{
  fonts.fontconfig.enable = true;
  home.packages = [
    (pkgs.nerdfonts.override { fonts = [ "Hack" ]; })
    pkgs.eza
    pkgs.ripgrep
    pkgs.nodejs_18
    pkgs.corepack_18
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
      hms = "home-manager switch";
      access = "cd ~/development/storyteq/access";
      api = "cd ~/development/storyteq/storyteq-api";
      platform = "cd ~/development/storyteq/storyteq-platform";
    };
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
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
      sink = "!git pull --rebase && git push";
      sync = "!git pull --rebase && git push";
      oops = "commit --amend --no-edit";
    };
    extraConfig = {
      checkout.defaultRemote = "origin";
      color.ui = true;
      rerere.enabled = true;
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      palette = "catppuccin_mocha";
      format = ''
        $directory$git_branch$git_commit$git_state$git_status$git_metrics$cmd_duration$nix_shell
        $character
      '';
      git_commit = { commit_hash_length = 5; };
      git_metrics = { disabled = false; };
      nix_shell = {
        disabled = false;
        heuristic = false;
        impure_msg = "[impure-shell](red)";
        pure_msg = "[pure-shell](green)";
        unknown_msg = "[unknown-shell](yellow)";
      };
    } // builtins.fromTOML (builtins.readFile (pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "starship";
      rev =
        "5629d2356f62a9f2f8efad3ff37476c19969bd4f"; # Replace with the latest commit hash
      sha256 = "sha256-nsRuxQFKbQkyEI4TXgvAjcroVdG+heKX5Pauq/4Ota0=";
    } + /palettes/mocha.toml));
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
