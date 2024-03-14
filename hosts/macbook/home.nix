{ pkgs, ... }:

{
  imports = [ ../../home/common.nix ../../home/programs/neovim ];
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
    gc = { automatic = true; };
  };
}
