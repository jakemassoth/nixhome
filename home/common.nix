{ pkgs, config, ... }: {
  catppuccin.enable = true;
  catppuccin.flavor = "mocha";
  home.packages = [
    pkgs.eza
    pkgs.ripgrep
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
  ];

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.tmux = {
    enable = true;

    keyMode = "vi";
    mouse = true;
    prefix = "C-a";

    terminal = "tmux-256color";

    shell = "${pkgs.zsh}/bin/zsh";
    # https://github.com/nix-community/home-manager/issues/5952
    extraConfig = ''
      set -g base-index 1
      set -g pane-base-index 1
      setw -g pane-base-index 1
      set -g renumber-windows on
      unbind %
      bind | split-window -h -c '#{pane_current_path}'

      unbind '"'
      bind - split-window -v -c '#{pane_current_path}'

      unbind p
      bind p previous-window

      bind-key -T copy-mode-vi 'v' send -X begin-selection # start selecting text with "v"
      bind-key -T copy-mode-vi 'y' send -X copy-selection # copy text with "y"

      unbind -T copy-mode-vi MouseDragEnd1Pane # don't exit copy mode after dragging with mouse
      set-option -sa terminal-overrides ',xterm-256color:RGB'
      set -g default-command "$SHELL"
    '';
    plugins = [
      {
        plugin = pkgs.tmuxPlugins.continuum;
        extraConfig = "set -g @continuum-restore 'on'";
      }
      {
        plugin = pkgs.tmuxPlugins.resurrect;
        extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      }
      pkgs.tmuxPlugins.vim-tmux-navigator
    ];
  };

  xdg.enable = true;

  programs.bat = { enable = true; };
  programs.btop = { enable = true; };
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.jq.enable = true;

  programs.zsh = {
    enable = true;
    shellAliases = {
      tmux = "tmux -f ~/.config/tmux/tmux.conf";
      nv = "source bw-anthropic; nvim .";
      hms = "home-manager switch";
      access = "cd ~/development/storyteq/access";
      api = "cd ~/development/storyteq/storyteq-api";
      platform = "cd ~/development/storyteq/storyteq-platform";
      lg = "lazygit";
      give_me_new_token = "~/give_me_new_token";
      ksd =
        "${pkgs.k9s}/bin/k9s --cluster gke_st-shared-dev-d7e8_europe-west1_st-shared-dev-gke";
      kpd =
        "${pkgs.k9s}/bin/k9s --cluster gke_st-platform-dev-5add_europe-west1_st-platform-dev-gke --name gke_st-platform-dev-5add_europe-west1_st-platform-dev-gke ";
    };
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    autocd = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "git-auto-fetch" ];
    };
  };

  # needed for signing commmits wit ssh
  home.file.".ssh/allowed_signers".text = ''
    * ${builtins.readFile "${config.home.homeDirectory}/.ssh/id_ed25519.pub"}
  '';

  home.file.".config/ghostty/config".text = ''
    theme = catppuccin-mocha
    font-family = CaskaydiaCove Nerd Font
    window-decoration = false
    font-thicken = true 
  '';

  programs.git = {
    enable = true;
    userEmail = "jakemassoth@storyteq.com";
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
      repositories = [ "${config.home.homeDirectory}/development/storyteq/ca" ];
    };
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
      gpg.ssh.allowedSignersFile =
        "${config.home.homeDirectory}/.ssh/allowed_signers";
    };
  };

  programs.lazygit = {
    enable = true;
    settings = { nerdFontsVersion = "3"; };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      format = ''
        $directory$git_branch$git_commit$git_state$git_status$git_metrics$nix_shell$cmd_duration
        $character
      '';
      git_commit = { commit_hash_length = 5; };
      git_metrics = { disabled = false; };
      nix_shell = {
        disabled = false;
        heuristic = true;
      };
    };
  };
  programs.k9s = { enable = true; };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
