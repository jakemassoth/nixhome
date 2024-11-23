{ pkgs, ... }: {
  programs.waybar = {
    enable = true;
    catppuccin.enable = true;
    style = ''
       #pulseaudio, #cpu, #memory, #temperature, #clock, #tray {
           padding: 0 10px;
       } 
       #workspaces button.focused {
           background: rgba(0, 0, 0, 0.2);
      }
    '';
    settings = [{
      modules-center = [ "hyprland/window" ];
      modules-left = [ "hyprland/workspaces" "sway/mode" ];
      modules-right = [
        "idle_inhibitor"
        "pulseaudio"
        "cpu"
        "memory"
        "temperature"
        "clock"
        "tray"
      ];
      clock = {
        format-alt = "{:%Y-%m-%d}";
        tooltip-format = "{:%Y-%m-%d | %H:%M}";
      };
      cpu = {
        format = "{usage}% ";
        tooltip = false;
      };
      memory = { format = "{}% "; };
      pulseaudio = {
        format = "{volume}% {icon} {format_source}";
        format-bluetooth = "{volume}% {icon} {format_source}";
        format-bluetooth-muted = " {icon} {format_source}";
        format-icons = {
          car = "";
          default = [ "" "" "" ];
          handsfree = "";
          headphones = "";
          headset = "";
          phone = "";
          portable = "";
        };
        format-muted = " {format_source}";
        format-source = " {volume}% ";
        format-source-muted = " ";
        on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
      };
      temperature = {
        critical-threshold = 80;
        format = "{temperatureC}°C {icon}";
        format-icons = [ "" "" "" ];
      };
    }];
  };
}
