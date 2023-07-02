{ config, pkgs, lib, ... }:

{
  imports = [ ./programs/neovim/neovim.nix ];
  fonts.fontconfig.enable = true;
  home.packages = [
    (pkgs.nerdfonts.override { fonts = [ "Hack" ]; })
    pkgs.exa
    pkgs.ripgrep
    pkgs.yarn
    pkgs.nodejs_18
  ];
  home.stateVersion = "22.11";

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
      ls = "exa";
      hms = "home-manager -f ~/.config/nixpkgs/$HOST/home.nix switch";
      odc = "owl devserver connect";
      ods = "owl shell devserver";
    };
    enableCompletion = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;
    autocd = true;
    initExtra = ''
      export PATH=/platform/bin:$PATH

      export PYENV_ROOT="$HOME/.pyenv"
      command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
      eval "$(pyenv init -)"


      export PATH="/Users/jakemassoth/.local/bin:$PATH"

      export NVM_DIR="$HOME/.nvm"
      [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
      [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
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
    userEmail = "jake@owlin.com";
    userName = "Jake Massoth";
    aliases = {
      s = "status";
      c = "commit -m";
      co = "checkout";
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
