{ config, pkgs, ... }:

{
  imports = [ ../../home/common.nix ];
  package = pkgs.nix;
  settings.experimental-features = [ "nix-command" "flakes" ];
  gc = { automatic = true; };
}
