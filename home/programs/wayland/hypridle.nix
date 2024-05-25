{ pkgs, lib, config, ... }: {
  services.hypridle = {
    enable = true;
    settings = {
      listener = [
        {
          timeout = 150;
          "on-timeout" = "${pkgs.brightnessctl}/bin/brightnessctl -s set 10";
          "on-resume" = "${pkgs.brightnessctl}/bin/brightnessctl -r";
        }
        {
          timeout = 300;
          "on-timeout" = "${pkgs.systemd}/bin/loginctl lock-session";
        }
        {
          timeout = 380;
          "on-timeout" = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
          "on-resume" = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
        }
      ];
      general = {
        "lock_cmd" = let hyprlock = lib.getExe config.programs.hyprlock.package;
        in "pidof ${hyprlock} || ${hyprlock}";
        "before_sleep_cmd" = "${pkgs.systemd}/bin/loginctl lock-session";
        "after_sleep_cmd" = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
      };
    };
  };
}
