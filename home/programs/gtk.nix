{ pkgs, ... }: {
  gtk = {
    enable = true;
    catppuccin.enable = true;
    iconTheme = {
      package = pkgs.gnome.adwaita-icon-theme;
      name = "Adwaita";
    };
  };
}
