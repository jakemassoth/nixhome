{flake-inputs, ...}: {
  imports = [
    flake-inputs.walker.homeManagerModules.default
    flake-inputs.zen-browser.homeModules.beta
    ../../home/common.nix
    ../../home/programs/neovim
    ../../home/programs/firefox.nix
    ../../home/programs/zen-browser.nix
    ../../home/programs/wayland
    ../../home/programs/gtk.nix
  ];
  home = {
    username = "jake";
    homeDirectory = "/home/jake";
    stateVersion = "23.11";
  };
}
