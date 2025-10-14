{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    systems.url = "github:nix-systems/default";

    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # darwin stuff
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    mac-app-util.url = "github:hraban/mac-app-util";
    walker.url = "github:abenz1267/walker";
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {nixpkgs, ...} @ inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs.flake-inputs = inputs;
      modules = [
        ./hosts/nixos/configuration.nix
      ];
    };
    nixosConfigurations.thinkpad = nixpkgs.lib.nixosSystem {
      specialArgs.flake-inputs = inputs;
      modules = [
        ./hosts/thinkpad/configuration.nix
        inputs.home-manager.nixosModules.default
        inputs.stylix.nixosModules.stylix
      ];
    };
    darwinConfigurations."STQ-FXG6LJWW26" = inputs.nix-darwin.lib.darwinSystem {
      specialArgs.flake-inputs = inputs;
      modules = [
        ./hosts/macbook/configuration.nix
        inputs.stylix.darwinModules.stylix
        inputs.mac-app-util.darwinModules.default
        inputs.home-manager.darwinModules.home-manager
        inputs.nix-homebrew.darwinModules.nix-homebrew
      ];
    };
  };
}
