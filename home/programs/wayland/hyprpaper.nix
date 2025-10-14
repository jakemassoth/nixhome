{pkgs, ...}: let
in {
  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "off";
    };
  };
}
