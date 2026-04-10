{
  pkgs,
  config,
  lib,
  ...
}: let
  customLib = import ../lib {inherit pkgs lib;};
  sshPubKeyPath = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
  hasSshKey = builtins.pathExists sshPubKeyPath;
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
      name = "tmux-sessionizer";
      text = builtins.readFile ./scripts/tmux-sessionizer.fish;
    })
    (customLib.writeFishApplication {
      name = "audit-repo";
      text = builtins.readFile ./scripts/audit-repo.fish;
    })

    (customLib.writeFishApplication {
      name = "reclaim-space";
      runtimeInputs = lib.optionals (!pkgs.stdenv.isDarwin) [pkgs.docker pkgs.nix];
      text = builtins.readFile ./scripts/reclaim-space.fish;
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
    pkgs.llama-cpp
    pkgs.devpod-desktop
    pkgs.fx
    pkgs.cachix
    pkgs.gh
    pkgs.nix-update
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.tmux = {
    enable = true;
    prefix = "C-a";
    mouse = true;
    keyMode = "vi";
    baseIndex = 1;
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
    ];
    extraConfig = ''
      # Explicitly set default-command so tmux-sensible doesn't override it
      # with reattach-to-user-namespace -l $SHELL (which would be zsh)
      set -g default-command "${pkgs.fish}/bin/fish"

      # Split panes with | and - (keep current path)
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %

      # vim-like pane navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Session switcher with fzf
      bind s display-popup -E "tmux list-sessions -F '#{session_name}' | fzf --prompt='Switch session: ' | xargs -r tmux switch-client -t"

      # Project finder (tmux-sessionizer)
      bind f display-popup -E "tmux-sessionizer"

      # New session
      bind N command-prompt -p "New session name:" "new-session -A -s '%%'"

      # Renumber windows when one is closed
      set -g renumber-windows on
    '';
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
  '';

  programs.git = {
    enable = true;
    lfs.enable = true;
    signing.format = null;
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
