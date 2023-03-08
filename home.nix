{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "jakemassoth";
  home.homeDirectory = "/Users/jakemassoth";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  fonts.fontconfig.enable = true;
  home.packages = [
    (pkgs.nerdfonts.override { fonts = [ "Hack" ]; })
  ];
  home.stateVersion = "22.11";
  # packages to install
  xdg.configFile.nvim = {
	source = ./nvim;
	recursive = true;
  };

  # TODO have nix manage plugins
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    extraLuaConfig = builtins.readFile ./nvim/init.lua;
  };

  # TODO have nix manage plugins
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


  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
