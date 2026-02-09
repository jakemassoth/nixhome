{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
    aerospace-homebrew = {
      url = "github:nikitabobko/homebrew-tap";
      flake = false;
    };
    walker = {
      url = "github:abenz1267/walker";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
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
    darwinConfigurations."Jakes-MacBook-Air" = inputs.nix-darwin.lib.darwinSystem {
      specialArgs.flake-inputs = inputs;
      modules = [
        ./hosts/personal-macbook/configuration.nix
      ];
    };
    darwinConfigurations."work-macbook" = inputs.nix-darwin.lib.darwinSystem {
      specialArgs.flake-inputs = inputs;
      modules = [
        ./hosts/work-macbook/configuration.nix
      ];
    };
  };
}
