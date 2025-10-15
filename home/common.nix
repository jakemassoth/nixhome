{
  pkgs,
  config,
  lib,
  ...
}: let
  customLib = import ../lib {inherit pkgs lib;};
in {
  home.packages = [
    pkgs.eza
    pkgs.ripgrep
    (customLib.writeFishApplication {
      name = "new-worktree";
      text = builtins.readFile ./scripts/new-worktree.fish;
    })

    (customLib.writeFishApplication {
      name = "cleanup-worktree";
      text = builtins.readFile ./scripts/cleanup-worktree.fish;
    })
    (customLib.writeFishApplication {
      name = "zet";
      text =
        builtins.replaceStrings
        ["@OBSIDIAN_DIR@"]
        ["${config.home.homeDirectory}/obsidian/main/00-inbox"]
        (builtins.readFile ./scripts/zet.fish);
    })
    pkgs.lazydocker
    pkgs.repomix
    pkgs.devpod
    pkgs.devcontainer
    pkgs.claude-code
    pkgs.xh
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.zellij = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      default_shell = "fish";
    };
  };

  xdg.enable = true;

  programs.bat = {
    enable = true;
  };
  programs.btop = {
    enable = true;
  };
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    changeDirWidgetCommand = "fd --type d";
  };

  programs.jq.enable = true;

  programs.fish = {
    enable = true;
    generateCompletions = true;
    shellAliases = {
      lg = "lazygit";
      give_me_new_token = "~/give_me_new_token";
      cat = "bat";
      ls = "eza";
      macos-rebuild = "sudo darwin-rebuild switch --flake ~/nixhome --impure";
    };
    interactiveShellInit = ''
      set -g fish_key_bindings fish_vi_key_bindings
      eval (${pkgs.zellij}/bin/zellij setup --generate-completion fish | string collect)
    '';
  };

  # needed for signing commmits wit ssh
  home.file.".ssh/allowed_signers".text = ''
    * ${builtins.readFile "${config.home.homeDirectory}/.ssh/id_ed25519.pub"}
  '';

  xdg.configFile."ghostty/config".text = ''
    theme = Catppuccin Mocha
    font-family = CaskaydiaCove Nerd Font
    window-decoration = false
    # font-thicken = true
    macos-option-as-alt = true
    shell-integration = fish
    command = ${pkgs.fish}/bin/fish
    keybind = alt+left=unbind
    keybind = alt+right=unbind
  '';

  programs.git = {
    enable = true;
    userEmail =
      if pkgs.stdenv.isDarwin
      then "jakemassoth@storyteq.com"
      else "jake@massoth.tech";
    userName = "Jake Massoth";
    lfs.enable = true;
    aliases = {
      s = "status";
      c = "commit -m";
      ca = "commit -am";
      co = "checkout";
      kick = "commit --allow-empty -m 'noop'";
      sink = "!git pull --rebase && git push";
      sync = "!git pull --rebase && git push";
      b = "blame -C -C -C";
      oops = "commit --amend --no-edit";
    };
    maintenance = {
      enable = true;
      repositories = ["${config.home.homeDirectory}/development/storyteq/ca"];
    };
    delta.enable = true;
    extraConfig = {
      checkout.defaultRemote = "origin";
      color.ui = true;
      rerere.enabled = true;
      pull.rebase = true;
      push.autoSetupRemote = true;
      column.ui = "auto";
      branch.sort = "-committerdate";
      gpg.format = "ssh";
      user.signingkey = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
      commit.gpgsign = true;
      tag.gpgsign = true;
      gpg.ssh.allowedSignersFile = "${config.home.homeDirectory}/.ssh/allowed_signers";
    };
  };

  programs.lazygit = {
    enable = true;
    settings = {
      nerdFontsVersion = "3";
    };
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      format = ''
        $directory$git_branch$git_commit$git_state$git_status$git_metrics$nix_shell$cmd_duration
        $character
      '';
      git_commit = {
        commit_hash_length = 5;
      };
      git_metrics = {
        disabled = false;
      };
      nix_shell = {
        disabled = false;
        heuristic = true;
      };
    };
  };
  programs.k9s = {
    enable = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  xdg.configFile."aerospace/aerospace.toml".source = ./programs/aerospace/config.toml;
}
