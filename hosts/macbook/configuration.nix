{ inputs, pkgs, ... }: {
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [ pkgs.wget ];
  fonts.packages = [ pkgs.nerd-fonts.caskaydia-cove ];

  # nix.package = pkgs.nix;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";
  nixpkgs.config.allowUnfree = true;
  nix.gc.automatic = true;
  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true; # default shell on catalina

  # Set Git commit hash for darwin-version.
  system.configurationRevision =
    inputs.self.rev or inputs.self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  # enable touch id to sudo
  security.pam.enableSudoTouchIdAuth = true;

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
    extraSpecialArgs = { inherit inputs; };
    users.jakemassoth = import ./home.nix;
    useGlobalPkgs = true;
    sharedModules = [ inputs.mac-app-util.homeManagerModules.default ];
  };
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "jakemassoth";
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };
  };
  homebrew = {
    enable = true;
    casks = [ "amethyst" "orbstack" "arc" "ghostty" ];
  };

  # auto hide menu bar
  system.defaults.NSGlobalDomain._HIHideMenuBar = true;
}
