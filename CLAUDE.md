# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Nix flake-based configuration repository managing multiple systems using NixOS (for Linux hosts) and nix-darwin (for macOS). It uses home-manager for user-level configuration across all platforms.

## Architecture

### Flake Structure

The `flake.nix` defines three system configurations:
- `nixosConfigurations.nixos` - Desktop NixOS system (systemd-boot)
- `nixosConfigurations.thinkpad` - Laptop NixOS system (GRUB)
- `darwinConfigurations."STQ-FXG6LJWW26"` - macOS system with homebrew integration

### Host Organization

Each host in `hosts/` contains:
- `configuration.nix` - System-level configuration
- `home.nix` - User-level home-manager configuration (imports from `home/`)
- `hardware-configuration.nix` - Hardware-specific settings
- Optional feature modules (e.g., `wayland.nix`, `steam.nix`, `video.nix`)

### Shared Configuration

- `home/common.nix` - Shared home-manager configuration across all systems (shells, git, tools, custom scripts)
- `home/programs/` - Program-specific configurations (neovim, firefox, wayland, gtk)
- User is `jake` on NixOS systems, `jakemassoth` on macOS

### Key Features

- Catppuccin Mocha theme across all systems
- Wayland/Hyprland setup for NixOS systems
- Fish shell with vi keybindings as primary shell
- Zellij terminal multiplexer with fish integration
- Custom worktree management scripts (`new-worktree`, `cleanup-worktree`)
- Git with SSH commit signing
- Neovim with comprehensive LSP setup for multiple languages
- macOS Touch ID for sudo authentication (including tmux support via pam-reattach)

## Common Commands

### Building and Switching

**NixOS systems:**
```bash
# From repository root on NixOS
sudo nixos-rebuild switch --flake .#nixos
sudo nixos-rebuild switch --flake .#thinkpad
```

**macOS:**
```bash
# From repository root on macOS
darwin-rebuild switch --flake . --impure
# Or use the fish alias (from home/common.nix):
macos-rebuild
```

### Updating Flake Inputs

```bash
nix flake update
```

### Garbage Collection

NixOS systems have automatic weekly garbage collection configured (deletes generations older than 30 days). Manual collection:
```bash
nix-collect-garbage --delete-older-than 30d
```

## Development Environment

### Neovim LSP Support

Neovim configuration (in `home/programs/neovim/default.nix`) includes LSPs for:
- Nix (nixd)
- Go (gopls)
- Python (pyright)
- JavaScript/TypeScript (typescript-language-server, vue-language-server)
- Svelte, Astro, PHP (intelephense), Elixir, Terraform, Helm, Markdown, Bash, Rust

Formatters: prettier, stylua, rustfmt, alejandra (Nix)

### Custom Utility Scripts

Defined in `home/common.nix` as shell scripts:
- `new-worktree <branch-name> [path]` - Creates git worktree with zellij session
- `cleanup-worktree` - Removes current worktree and kills zellij session
- `zet [filename]` - Creates timestamped markdown notes in Obsidian vault

### Custom Nix Helpers

Available in `lib/` directory:
- `writeFishApplication` - Helper for creating Fish shell scripts with runtime dependencies, similar to `writeShellApplication`
  - Usage: Import via `customLib = import ../lib {inherit pkgs lib;};` in home-manager modules
  - Supports `runtimeInputs`, `runtimeEnv`, `inheritPath`, and automatic Fish syntax checking
  - See `EXAMPLE_FISH_APP.md` for usage examples

## Important Notes

- Fish shell configuration uses vi keybindings
- Git is configured for SSH signing (requires `~/.ssh/id_ed25519.pub`)
- Git push auto-setup-remote is enabled
- macOS uses homebrew for GUI applications (Arc, Ghostty, Raycast, AeroSpace, Claude, Orion)
- NixOS hosts use pipewire for audio
- Docker virtualization enabled on NixOS systems
- unfree packages are allowed across all systems
