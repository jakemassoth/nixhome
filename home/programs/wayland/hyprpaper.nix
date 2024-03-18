{ pkgs, ... }:
let
  wallpaper = "${
      pkgs.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixos-artwork";
        rev = "35ebbbf01c3119005ed180726c388a01d4d1100c";
        hash = "sha256-t6UXqsBJhKtZEriWdrm19HIbdyvB6V9dR47WHFxENhc=";
      }
    }/wallpapers/nixos-wallpaper-catppuccin-mocha.png";
in {
  services.hyprpaper = {
    enable = true;
    preloads = [ wallpaper ];
    wallpapers = [ "DP-1,${wallpaper}" ];
  };
}
