{ config, pkgs, lib, ... }:

{
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require 'wezterm'
      local config = wezterm.config_builder()
      config.color_scheme = "Catppuccin Mocha"
      config.font = wezterm.font 'CaskaydiaCove Nerd Font'
      config.font_size = 14.0
      config.enable_tab_bar = false
      config.window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
      }
      config.window_decorations = "RESIZE"
      return config
    '';
  };
}
