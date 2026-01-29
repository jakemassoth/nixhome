# Repository Guidelines

## Project Structure & Module Organization
- `flake.nix` and `flake.lock` define inputs and system outputs for NixOS and macOS.
- `hosts/` contains per-machine configs: each host has `configuration.nix`, `home.nix`, and optional feature modules like `wayland.nix` or `steam.nix`.
- `home/` holds shared Home Manager setup (`home/common.nix`) and program modules under `home/programs/` (e.g., `neovim/`, `wayland/`, `firefox.nix`).
- `lib/` provides local helpers like `writeFishApplication.nix` (see `EXAMPLE_FISH_APP.md`).
- `home/scripts/` contains small Fish utilities (e.g., `new-worktree.fish`).

## Build, Test, and Development Commands
- `sudo nixos-rebuild switch --flake .#nixos` or `.#thinkpad`: apply system config on NixOS.
- `darwin-rebuild switch --flake . --impure` (or `macos-rebuild`): apply config on macOS.
- `nix flake update`: update flake inputs.
- `nix-collect-garbage --delete-older-than 30d`: manual cleanup (NixOS also runs weekly GC).

## Coding Style & Naming Conventions
- Nix files use 2-space indentation and keep expressions small and modular; prefer extracting into `home/programs/` or `hosts/<name>/` modules.
- Filenames are descriptive and lowercase with hyphens (e.g., `hardware-configuration.nix`).
- Formatting tools used in editor configs include `alejandra` for Nix and language-specific formatters via Neovim.

## Testing Guidelines
- No dedicated test framework is defined; validate changes by switching the target system.
- Prefer dry-run checks when possible: `nix flake check` if inputs support it.
- For script changes, run the script directly (e.g., `home/scripts/new-worktree.fish`).

## Commit & Pull Request Guidelines
- Recent commit history uses short, lowercase, present-tense messages (e.g., `flake update`, `add thinkpad config`). Follow that pattern.
- PRs should describe the target host, modules touched, and any manual steps needed to apply changes. Include screenshots only for UI/desktop tweaks.

## Security & Configuration Tips
- Keep secrets out of the repo; store host-specific sensitive values in system-specific files or external secret managers.
- macOS uses Homebrew for GUI apps; NixOS uses Nix packages—avoid mixing unless intentional.
