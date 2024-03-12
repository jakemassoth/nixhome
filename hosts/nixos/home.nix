{ config, pkgs, ... }:

{
  imports = [
    ../../home/common.nix
    ../../home/programs/alacritty.nix
    ../../home/programs/firefox.nix
  ];
  home = {
    username = "jake";
    homeDirectory = "/home/jake";
    stateVersion = "24.05";
  };
}
