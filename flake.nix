{
  description = "Home Manager configuration of Jake Massoth";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { home-manager, nixpkgs, ... }:
    let
      system = "aarch64-darwin";
      homeDirectory = "/Users/jakemassoth";
      username = "jakemassoth";
    in {
      defaultPackage.${system} = home-manager.defaultPackage.${system};
      homeConfigurations.${username} =
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          modules = [
            ./home/common.nix
            {
              home = {
                inherit username;
                homeDirectory = "/Users/${username}";
                stateVersion = "24.05";
              };
            }
          ];
        };
    };
}
