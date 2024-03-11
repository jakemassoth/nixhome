{ config, pkgs, ... }:

{
  imports = [ ../../home/common.nix ../../home/programs/alacritty.nix ];
  home.username = "jake";
  home.homeDirectory = "/home/jake";
  home.stateVersion = "24.05";
}
