{
  username,
  homeDirectory,
}: {...}: {
  imports = [
    ../home/common.nix
    ../home/programs/neovim
  ];
  home = {
    inherit username homeDirectory;
    stateVersion = "23.11";
  };
}
