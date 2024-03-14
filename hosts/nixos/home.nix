{ config, inputs, ... }:

{
  imports = [
    inputs.hyprlock.homeManagerModules.default
    inputs.hypridle.homeManagerModules.default
    ../../home/common.nix
    ../../home/programs/neovim
    ../../home/programs/alacritty.nix
    ../../home/programs/firefox.nix
    ../../home/programs/wayland
    ../../home/programs/gtk.nix
  ];
  home = {
    username = "jake";
    homeDirectory = "/home/jake";
    stateVersion = "24.05";
  };
}
