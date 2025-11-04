{pkgs, ...}: {
  stylix = {
    enable = true;

    # Use Catppuccin Mocha as the base16 color scheme
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

    # Generate a solid color wallpaper using the base16 scheme
    image = pkgs.runCommand "wallpaper.png" {} ''
      ${pkgs.imagemagick}/bin/convert -size 1920x1080 xc:#1e1e2e $out
    '';

    # Font configuration
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.caskaydia-cove;
        name = "CaskaydiaCove Nerd Font";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
    };

    # Configure font sizes
    fonts.sizes = {
      applications = 12;
      terminal = 11;
      desktop = 11;
      popups = 11;
    };
  };
}
