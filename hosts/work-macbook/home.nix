{...}: {
  imports = [
    ../../home/common.nix
    ../../home/programs/neovim
  ];
  home = {
    username = "jake";
    homeDirectory = "/Users/jake";
    stateVersion = "23.11";
  };
}
