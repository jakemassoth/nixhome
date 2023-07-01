{ config, pkgs, lib, ... }:

{
  imports = [ ../home/common.nix ];
  home.username = "jake";
  home.homeDirectory = "/home/jake";

  programs.home-manager.enable = true;
}
