{ config, pkgs, lib, ... }: {
  programs.alacritty = {
    enable = true;
    catppuccin.enable = true;
    settings = {
      env = {
        "TERM" = "xterm-256color";
        "WINIT_X11_SCALE_FACTOR" = "1";
      };
      font = {
        size = 11.0;
        normal.family = "CaskaydiaCove Nerd Font";
        bold.family = "CaskaydiaCove Nerd Font";
        italic.family = "CaskaydiaCove Nerd Font";
      };
      terminal = { shell = { program = "zsh"; }; };
      window = { decorations = "None"; };
    };
  };
}
