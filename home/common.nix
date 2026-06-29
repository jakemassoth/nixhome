{
  pkgs,
  config,
  lib,
  flake-inputs,
  ...
}: let
  customLib = import ../lib {inherit pkgs lib;};
  sshPubKeyPath = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
  hasSshKey = builtins.pathExists sshPubKeyPath;
  system = pkgs.stdenv.hostPlatform.system;
  pi = flake-inputs.self.packages.${system}.pi;
  claude-code = flake-inputs.self.packages.${system}.claude-code;
in {
  imports = [
    ./programs/claude-hooks.nix
  ];

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
      name = "notify-me";
      runtimeInputs = lib.optionals (!pkgs.stdenv.isDarwin) [pkgs.libnotify];
      text = builtins.readFile ./scripts/notify-me.fish;
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
      name = "compress-recording";
      runtimeInputs = [pkgs.fzf pkgs.ffmpeg];
      text = builtins.readFile ./scripts/compress-recording.fish;
    })

    (customLib.writeFishApplication {
      name = "dj-set";
      runtimeInputs = [pkgs.yt-dlp pkgs.mpv pkgs.ffmpeg];
      runtimeEnv = {
        FFMPEG = "${pkgs.ffmpeg}/bin/ffmpeg";
      };
      text = builtins.readFile ./scripts/dj-set.fish;
    })

    (customLib.writeFishApplication {
      name = "dj-set-clean";
      runtimeInputs = [pkgs.fzf];
      text = builtins.readFile ./scripts/dj-set-clean.fish;
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
    pkgs.devcontainer
    claude-code
    pi
    pkgs.xh
    pkgs.fx
    pkgs.cachix
    pkgs.gh
    pkgs.nix-update
    pkgs.dive
    pkgs.google-cloud-sdk
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
      fish_add_path -g $HOME/.local/bin

      # Rosé Pine Moon theme (https://github.com/rose-pine/fish)
      set -g fish_color_normal e0def4
      set -g fish_color_command c4a7e7
      set -g fish_color_keyword 9ccfd8
      set -g fish_color_quote f6c177
      set -g fish_color_redirection 3e8fb0
      set -g fish_color_end 908caa
      set -g fish_color_error eb6f92
      set -g fish_color_param ea9a97
      set -g fish_color_comment 908caa
      set -g fish_color_selection --reverse
      set -g fish_color_operator e0def4
      set -g fish_color_escape 3e8fb0
      set -g fish_color_autosuggestion 908caa
      set -g fish_color_cwd ea9a97
      set -g fish_color_user f6c177
      set -g fish_color_host 9ccfd8
      set -g fish_color_host_remote c4a7e7
      set -g fish_color_cancel e0def4
      set -g fish_color_search_match --background=232136
      set -g fish_color_valid_path
      set -g fish_pager_color_progress ea9a97
      set -g fish_pager_color_background --background=2a273f
      set -g fish_pager_color_prefix 9ccfd8
      set -g fish_pager_color_completion 908caa
      set -g fish_pager_color_description 908caa
      set -g fish_pager_color_secondary_background
      set -g fish_pager_color_secondary_prefix
      set -g fish_pager_color_secondary_completion
      set -g fish_pager_color_secondary_description
      set -g fish_pager_color_selected_background --background=393552
      set -g fish_pager_color_selected_prefix 9ccfd8
      set -g fish_pager_color_selected_completion e0def4
      set -g fish_pager_color_selected_description e0def4
      set -g fish_color_subtle 908caa
      set -g fish_color_text e0def4
      set -g fish_color_love eb6f92
      set -g fish_color_gold f6c177
      set -g fish_color_rose ea9a97
      set -g fish_color_pine 3e8fb0
      set -g fish_color_foam 9ccfd8
      set -g fish_color_iris c4a7e7
      set -g fish_color_base 232136
    '';
  };

  home.file = lib.optionalAttrs hasSshKey {
    # needed for signing commmits wit ssh
    ".ssh/allowed_signers".text = ''
      * ${builtins.readFile sshPubKeyPath}
    '';
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    signing.format = null;
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
        $directory$git_branch$git_commit$git_state$git_status$git_metrics$nix_shell$custom$cmd_duration
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
      custom.firebase = {
        command = ''node -e "try{const f=require(process.env.HOME+'/.config/configstore/firebase-tools.json');console.log(f.activeProjects[process.cwd()]||''')}catch(e){}"'';
        when = ''node -e "try{const f=require(process.env.HOME+'/.config/configstore/firebase-tools.json');const p=f.activeProjects[process.cwd()];process.exit(p&&p.includes('prod')?0:1)}catch(e){process.exit(1)}"'';
        format = "[⚠ PROD:$output]($style) ";
        style = "bold red";
      };
    };
  };
  programs.k9s = {
    enable = true;
  };

  programs.wezterm = {
    enable = true;
    # App is installed via Homebrew cask (see common/darwin.nix) so it lives at a
    # stable /Applications path and macOS TCC permissions (Full Disk Access, etc.)
    # persist across rebuilds. Home Manager only manages ~/.config/wezterm/wezterm.lua.
    package = pkgs.emptyDirectory;
    extraConfig = ''
      local fish_path = "${pkgs.fish}/bin/fish"
      ${builtins.readFile ./programs/wezterm/config.lua}
    '';
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  xdg.configFile."aerospace/aerospace.toml" = lib.mkIf pkgs.stdenv.isDarwin {
    source = ./programs/aerospace/config.toml;
  };
}
