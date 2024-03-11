{ config, pkgs, lib, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      env = { "TERM" = "xterm-256color"; };
      font = {
        size = 11.0;

        normal.family = "Hack Nerd Font";
        bold.family = "Hack Nerd Font";
        italic.family = "Hack Nerd Font";
      };
      shell = { program = "zsh"; };
      # window = {
      #   decorations = "none";
      #   startup_mode = "Maximized";
      # };
      colors = {
        primary = {
          background = "#1E1E2E";
          foreground = "#CDD6F4";
          dim_foreground = "#CDD6F4";
          bright_foreground = "#CDD6F4";
        };

        cursor = {
          text = "#1E1E2E";
          cursor = "#F5E0DC";
        };
        normal = {
          black = "#45475A";
          red = "#F38BA8";
          green = "#A6E3A1";
          yellow = "#F9E2AF";
          blue = "#89B4FA";
          magenta = "#F5C2E7";
          cyan = "#94E2D5";
          white = "#BAC2DE";
        };

        bright = {
          black = "#585B70";
          red = "#F38BA8";
          green = "#A6E3A1";
          yellow = "#F9E2AF";
          blue = "#89B4FA";
          magenta = "#F5C2E7";
          cyan = "#94E2D5";
          white = "#A6ADC8";
        };

        dim = {
          black = "#45475A";
          red = "#F38BA8";
          green = "#A6E3A1";
          yellow = "#F9E2AF";
          blue = "#89B4FA";
          magenta = "#F5C2E7";
          cyan = "#94E2D5";
          white = "#BAC2DE";
        };

        # [colors.vi_mode_cursor]
        # text = "#1E1E2E"
        # cursor = "#B4BEFE"
        #
        # [colors.search.matches]
        # foreground = "#1E1E2E"
        # background = "#A6ADC8"
        #
        # [colors.search.focused_match]
        # foreground = "#1E1E2E"
        # background = "#A6E3A1"
        #
        # [colors.footer_bar]
        # foreground = "#1E1E2E"
        # background = "#A6ADC8"
        #
        # [colors.hints.start]
        # foreground = "#1E1E2E"
        # background = "#F9E2AF"
        #
        # [colors.hints.end]
        # foreground = "#1E1E2E"
        # background = "#A6ADC8"
        #
        # [colors.selection]
        # text = "#1E1E2E"
        # background = "#F5E0DC"
        #
        # [colors.normal]
        # black = "#45475A"
        # red = "#F38BA8"
        # green = "#A6E3A1"
        # yellow = "#F9E2AF"
        # blue = "#89B4FA"
        # magenta = "#F5C2E7"
        # cyan = "#94E2D5"
        # white = "#BAC2DE"
        #
        # [colors.bright]
        # black = "#585B70"
        # red = "#F38BA8"
        # green = "#A6E3A1"
        # yellow = "#F9E2AF"
        # blue = "#89B4FA"
        # magenta = "#F5C2E7"
        # cyan = "#94E2D5"
        # white = "#A6ADC8"
        #
        # [colors.dim]
        # black = "#45475A"
        # red = "#F38BA8"
        # green = "#A6E3A1"
        # yellow = "#F9E2AF"
        # blue = "#89B4FA"
        # magenta = "#F5C2E7"
        # cyan = "#94E2D5"
        # white = "#BAC2DE"
        #
        # [[colors.indexed_colors]]
        # index = 16
        # color = "#FAB387"
        #
        # [[colors.indexed_colors]]
        # index = 17
        # color = "#F5E0DC"

      };
    };

  };

}
