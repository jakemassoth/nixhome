{
  pkgs,
  config,
  lib,
  ...
}: let
  customLib = import ../lib {inherit pkgs lib;};
  sshPubKeyPath = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
  hasSshKey = builtins.pathExists sshPubKeyPath;
  rustToolchain = pkgs.rust-bin.nightly.latest.default;
  cargoWithBindeps = pkgs.writeShellScriptBin "cargo" ''
    export CARGO_HOME="''${CARGO_HOME:-$TMPDIR/cargo-home}"
    mkdir -p "$CARGO_HOME"
    cat >"$CARGO_HOME/config.toml" <<'EOF'
    [unstable]
    bindeps = true
    EOF
    exec ${rustToolchain}/bin/cargo "$@"
  '';
  rustPlatform = pkgs.makeRustPlatform {
    cargo = cargoWithBindeps;
    rustc = rustToolchain;
  };
  codex = pkgs.callPackage ./codex.nix {inherit rustPlatform;};
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
    codex
    pkgs.llama-cpp
    pkgs.devpod-desktop
    pkgs.fx
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
  home.file = lib.mkIf hasSshKey {
    ".ssh/allowed_signers".text = ''
      * ${builtins.readFile sshPubKeyPath}
    '';
  };

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
    lfs.enable = true;
    maintenance = {
      enable = true;
      repositories = ["${config.home.homeDirectory}/development/storyteq/ca"];
    };
    settings =
      {
        user =
          {
            email = "jake@massoth.tech";
            name = "Jake Massoth";
          }
          // lib.optionalAttrs hasSshKey {
            signingkey = sshPubKeyPath;
          };
        alias = {
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
        checkout.defaultRemote = "origin";
        color.ui = true;
        rerere.enabled = true;
        pull.rebase = true;
        push.autoSetupRemote = true;
        column.ui = "auto";
        branch.sort = "-committerdate";
      }
      // lib.optionalAttrs hasSshKey {
        gpg.format = "ssh";
        commit.gpgsign = true;
        tag.gpgsign = true;
        gpg.ssh.allowedSignersFile = "${config.home.homeDirectory}/.ssh/allowed_signers";
      };
  };

  programs.delta.enable = true;
  programs.delta.enableGitIntegration = true;

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
