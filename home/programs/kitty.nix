{ config, pkgs, lib, ... }: {
  programs.kitty = {
    enable = true;
    catppuccin.enable = true;
    font = {
      size = 10.0;
      name = "CaskaydiaCove Nerd Font";
      package = pkgs.nerd-fonts.caskaydia-cove;
    };
  };
}
