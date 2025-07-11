{
  config,
  pkgs,
  ...
}: let
  lockscreenWallpaper = "${
    pkgs.fetchFromGitHub {
      owner = "NixOS";
      repo = "nixos-artwork";
      rev = "35ebbbf01c3119005ed180726c388a01d4d1100c";
      hash = "sha256-t6UXqsBJhKtZEriWdrm19HIbdyvB6V9dR47WHFxENhc=";
    }
  }/wallpapers/nixos-wallpaper-catppuccin-mocha.png";
in {
  programs.hyprlock = {
    enable = true;
    settings = {
      background = [
        {
          monitor = "";
          path = lockscreenWallpaper;
        }
      ];

      label = [
        {
          monitor = "";
          text = "$TIME";
          font_size = 50;

          position = "0, 500";

          valign = "center";
          halign = "center";
        }
      ];
    };
  };
}
