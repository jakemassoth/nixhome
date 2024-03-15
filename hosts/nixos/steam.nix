{ pkgs, inputs, ... }: {
  programs.gamemode.enable = true;
  programs.steam = {
    enable = true;
    extraCompatPackages =
      [ inputs.nix-gaming.packages.${pkgs.system}.proton-ge ];
  };
}
