{ inputs, ... }:

{
  imports = [
    inputs.catppuccin.homeManagerModules.catppuccin
    ../../home/common.nix
    ../../home/programs/neovim
  ];
  home = {
    username = "jakemassoth";
    homeDirectory = "/Users/jakemassoth";
    stateVersion = "23.11";
  };
}
