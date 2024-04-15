{ config, pkgs, lib, ... }:

{
  programs.alacritty = {
    enable = true;
    catppuccin.enable = true;
    settings = {
      env = { "TERM" = "xterm-256color"; };
      font = {
        size = 14.0;

        normal.family = "Hack Nerd Font";
        bold.family = "Hack Nerd Font";
        italic.family = "Hack Nerd Font";
      };
      shell = { program = "zsh"; };
    };
  };
}
