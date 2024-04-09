{ pkgs, ... }: {
  gtk = {
    enable = true;
    catppuccin.enable = true;
    catppuccin.cursor.enable = true;
    # theme = {
    #   name = "Catppuccin-Mocha-Standard-Blue-Dark";
    #   package = pkgs.catppuccin-gtk.override { variant = "mocha"; };
    # };
    iconTheme = {
      package = pkgs.gnome.adwaita-icon-theme;
      name = "Adwaita";
    };
  };
}
