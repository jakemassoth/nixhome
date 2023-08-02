{ config, pkgs, lib, ... }:

{
  imports = [ ../home/common.nix ];
  home.username = "jakemassoth";
  home.homeDirectory = "/Users/jakemassoth";

  programs.home-manager.enable = true;
}
