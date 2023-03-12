{ config, pkgs, lib, ... }:

{
  imports = [ ../home/common.nix ];
  home.username = "ubuntu";
  home.homeDirectory = "/home/ubuntu";

  programs.home-manager.enable = true;
}
