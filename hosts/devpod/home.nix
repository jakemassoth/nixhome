{ inputs, ... }:
{
  imports = [
    inputs.catppuccin.homeManagerModules.catppuccin
    ../../home/common.nix
    ../../home/programs/neovim
  ];
  home = {
    username = "vscode";
    homeDirectory = "/home/vscode";
    stateVersion = "23.11";
  };
}
