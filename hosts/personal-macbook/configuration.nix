{
  flake-inputs,
  pkgs,
  ...
}: let
  taps = {
    "homebrew/homebrew-core" = flake-inputs.homebrew-core;
    "homebrew/homebrew-cask" = flake-inputs.homebrew-cask;
    "nikitabobko/homebrew-tap" = flake-inputs.aerospace-homebrew;
  };
in {
  imports = [
    flake-inputs.home-manager.darwinModules.home-manager
    flake-inputs.stylix.darwinModules.stylix
    flake-inputs.nix-homebrew.darwinModules.nix-homebrew
    ../../common/stylix.nix
  ];

  nixpkgs.overlays = [flake-inputs.rust-overlay.overlays.default];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  system.primaryUser = "jakemassoth";
  environment.systemPackages = [pkgs.wget];
  fonts.packages = [pkgs.nerd-fonts.caskaydia-cove];

  # nix.package = pkgs.nix;
  nix.enable = false;

  # Necessary for using flakes on this system.
  nixpkgs.config.allowUnfree = true;
  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina
  programs.fish.enable = true;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = flake-inputs.self.rev or flake-inputs.self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  # enable touch id to sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # make it work in tmux as well
  environment = {
    etc."pam.d/sudo_local".text = ''
      # Managed by Nix Darwin
      auth       optional       ${pkgs.pam-reattach}/lib/pam/pam_reattach.so ignore_ssh
      auth       sufficient     pam_tid.so
    '';
  };

  users.users.jakemassoth.home = "/Users/jakemassoth";
  home-manager = {
    users.jakemassoth = import ./home.nix;
    useGlobalPkgs = true;
    extraSpecialArgs = {inherit flake-inputs;};
  };
  nix-homebrew = {
    enable = true;

    enableRosetta = true;

    user = "jakemassoth";
    taps = taps;
    mutableTaps = false;
    autoMigrate = true;
  };
  homebrew = {
    enable = true;
    casks = [
      "orbstack"
      "ghostty"
      "raycast"
      "nikitabobko/tap/aerospace"
      "claude"
      "orion"
      "bitwarden"
      "obsidian"
      "anki"
      "chatgpt"
      "google-chrome"
      "spotify"
    ];
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
    taps = builtins.attrNames taps;
  };

  # auto hide menu bar
  system.defaults.NSGlobalDomain._HIHideMenuBar = true;
}
