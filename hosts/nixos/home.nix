{
  config,
  inputs,
  ...
}: {
  imports = [
    inputs.catppuccin.homeManagerModules.catppuccin
    ../../home/common.nix
    ../../home/programs/neovim
    ../../home/programs/firefox.nix
    ../../home/programs/wayland
    ../../home/programs/gtk.nix
  ];
  home = {
    username = "jake";
    homeDirectory = "/home/jake";
    stateVersion = "23.11";
  };
}
