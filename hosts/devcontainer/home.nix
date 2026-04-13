{...}: {
  imports = [
    ../../home/common.nix
    ../../home/programs/neovim
  ];
  home = {
    username = builtins.getEnv "USER";
    homeDirectory = builtins.getEnv "HOME";
    stateVersion = "23.11";
  };
}
