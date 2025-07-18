{pkgs, ...}: let
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
    settings = {
      ipc = "off";
      preload = [wallpaper];
      wallpaper = ["DP-3,${wallpaper}" "DP-2,${wallpaper}" "DP-1,${wallpaper}"];
    };
  };
}
