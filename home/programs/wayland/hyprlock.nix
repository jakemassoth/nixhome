{ config, ... }:

{
  programs.hyprlock = {
    enable = true;

    backgrounds = [{
      monitor = "";
      path = "${config.home.homeDirectory}/wallpaper.png";
    }];

    labels = [{
      monitor = "";
      text = "$TIME";
      font_size = 50;

      position = {
        x = 0;
        y = 320;
      };

      valign = "center";
      halign = "center";
    }];
  };
}
