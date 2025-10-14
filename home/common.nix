{
  pkgs,
  config,
  ...
}: {
  home.packages = [
    pkgs.eza
    pkgs.ripgrep
    (pkgs.writeShellScriptBin "new-worktree" ''
      DEFAULT_BASE_DIR="$HOME/development/storyteq/monorepo-worktrees"

      # Check if correct number of arguments provided
      if [ $# -lt 1 ] || [ $# -gt 2 ]; then
          echo "Usage: $0 <branch-name> [folder-path]"
          echo "Example: $0 feature/new-feature"
          echo "Example: $0 feature/new-feature ~/custom/path"
          echo "Default base directory: $DEFAULT_BASE_DIR"
          exit 1
      fi

      BRANCH_NAME="$1"

      # Use provided folder path or construct default
      if [ $# -eq 2 ]; then
          FOLDER_PATH="$2"
      else
          # Create folder name from branch name (replace / with -)
          FOLDER_NAME=$(echo "$BRANCH_NAME" | sed 's/\//-/g')
          FOLDER_PATH="$DEFAULT_BASE_DIR/$FOLDER_NAME"
      fi

      echo "🔄 Fetching from origin..."
      git fetch origin

      # Create the base directory if it doesn't exist (when using default)
      if [ $# -eq 1 ]; then
          mkdir -p "$(dirname "$FOLDER_PATH")"
      fi

      echo "🌿 Creating new worktree '$BRANCH_NAME' in '$FOLDER_PATH'..."
      git worktree add -b "$BRANCH_NAME" "$FOLDER_PATH" origin/main

      echo "📁 Worktree created successfully!"

      # Get the absolute path of the folder
      ABS_FOLDER_PATH=$(realpath "$FOLDER_PATH")

      SESSION_NAME=$(echo "$BRANCH_NAME" | sed 's/[^a-zA-Z0-9_-]/_/g')


      echo "activating direnv in $ABS_FOLDER_PATH"
      direnv allow $ABS_FOLDER_PATH

      echo "🚀 now attach to zellij session $SESSION_NAME and cd into $ABS_FOLDER_PATH (in clipboard)"
      echo "z $ABS_FOLDER_PATH" | pbcopy

      exec zellij attach -b "$SESSION_NAME"
    '')

    (pkgs.writeShellScriptBin "cleanup-worktree" ''
      # Check if we're in a Git repository
      if ! git rev-parse --git-dir > /dev/null 2>&1; then
          echo "Error: Not in a Git repository"
          exit 1
      fi

      # Get the current directory (the worktree we want to delete)
      CURRENT_DIR=$(pwd)
      BRANCH_NAME=$(git branch --show-current)

      echo "🔍 Current worktree:"
      echo "  Branch: $BRANCH_NAME"
      echo "  Path: $CURRENT_DIR"
      echo ""

      # Confirmation
      read -p "Delete this worktree and kill current Zellij session? (y/N): " -n 1 -r
      echo
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
          echo "Cleanup cancelled"
          exit 0
      fi

      # Move out of the worktree directory before removing it
      echo "📁 Moving to parent git directory..."
      cd "$(git rev-parse --show-superproject-working-tree || git rev-parse --show-toplevel)"

      # Remove the worktree
      echo "🗑️  Removing Git worktree '$CURRENT_DIR'..."
      git worktree remove "$CURRENT_DIR" --force

      echo "🎉 Cleanup completed!"

      # Kill current Zellij session if we're in one (do this last)
      if [ -n "$ZELLIJ_SESSION_NAME" ]; then
          echo "🔪 Killing current Zellij session '$ZELLIJ_SESSION_NAME'..."
          sleep 1
          zellij kill-session "$ZELLIJ_SESSION_NAME"
      else
          echo "ℹ️  Not in a Zellij session"
      fi
    '')
    (pkgs.writeShellScriptBin "zet" ''
      # function to prompt the user for a filename
      get_filename() {
      	read -p "Enter a filename: " filename
      	echo "$filename"
      }

      # function to create and open a file in the specified directory
      open_file() {

      	# Cd into the directory
      	cd "$1" || exit
      	# Create the file in the specified directory
      	touch "$1/$filename.md"

      	# create unique identifier and links section
      	timestamp="$(date +"%Y%m%d%H%M")"

      	# format the file
      	{
      		echo "# "
      		echo -en "\n"
      		echo -en "\n"
      		echo -en "\n"
      		echo "Links:"
      		echo -en "\n"
      		echo "$timestamp"
      	} >>"$1/$filename.md"

      	# Open the file in Neovim
      	nvim '+ normal ggzzi' "$1/$filename.md"
      }

      # Prompt the user if no filename is provided
      if [[ $# -eq 0 ]]; then
      	filename=$(get_filename)
      fi

      # if more than one argument is given, print error message and stop script
      if [[ $# -gt 1 ]]; then
      	echo "Please provide only one filename separated by dashes, without .md extension."
      	echo "Example: zet my-new-note"
      	exit 1
      fi

      # set filename to the argument given to the script
      if [[ $# -eq 1 ]]; then
      	filename=$1
      fi

      open_file "${config.home.homeDirectory}/obsidian/main/00-inbox"
    '')
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

  programs.qutebrowser = {
    enable = true;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  xdg.configFile."aerospace/aerospace.toml".source = ./programs/aerospace/config.toml;
}
