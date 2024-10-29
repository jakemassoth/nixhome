{ config, pkgs, lib, ... }:

{
  programs.alacritty = {
    enable = true;
    catppuccin.enable = true;
    settings = {
      env = { "TERM" = "xterm-256color"; };
      font = {
        size = 14.0;

        normal.family = "CaskaydiaCove Nerd Font";
        bold.family = "CaskaydiaCove Nerd Font";
        italic.family = "CaskaydiaCove Nerd Font";
      };
      shell = { program = "zsh"; };
    };
  };
}
