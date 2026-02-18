{
  system ? builtins.currentSystem,
  overlays ? [],
}:
let
  pkgs = import <nixpkgs> {
    inherit system overlays;
  };
in {
  codex = pkgs.callPackage ./home/codex.nix {
    rustPlatform = pkgs.rustPlatform;
  };
}
