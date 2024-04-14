{ pkgs, ... }: {
  programs.gamemode.enable = true;
  programs.steam = {
    # package = pkgs.steam.override {
    #   extraPkgs = pkgs:
    #     with pkgs; [
    #       xorg.libXcursor
    #       xorg.libXi
    #       xorg.libXinerama
    #       xorg.libXScrnSaver
    #       libpng
    #       libpulseaudio
    #       libvorbis
    #       stdenv.cc.cc.lib
    #       libkrb5
    #       keyutils
    #     ];
    # };
    enable = true;
    gamescopeSession.enable = true;
    extraCompatPackages = with pkgs; [ proton-ge-bin ];
  };
}
