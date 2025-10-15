{
  pkgs,
  lib,
}:
rec {
  writeFishApplication = pkgs.callPackage ./writeFishApplication.nix {};
}
