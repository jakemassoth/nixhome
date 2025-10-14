{
  config,
  pkgs,
  ...
}: {
  programs.hyprlock = {
    enable = true;
    settings = {
      # Background is handled by Stylix

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
