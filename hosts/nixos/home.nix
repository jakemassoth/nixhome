{ config, ... }:

{
  imports = [
    ../../home/common.nix
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
