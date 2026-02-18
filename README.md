# nixhome

## Update the `codex` package

Run from the repository root:

```sh
nix-update -f ./.nix-update-codex.nix codex \
  --override-filename home/codex.nix \
  --version-regex '^rust-v(\d+\.\d+\.\d+)$'
```

If `nix-update` is not installed:

```sh
nix run nixpkgs#nix-update -- -f ./.nix-update-codex.nix codex \
  --override-filename home/codex.nix \
  --version-regex '^rust-v(\d+\.\d+\.\d+)$'
```

Notes:
- The wrapper file `./.nix-update-codex.nix` is required because `home/codex.nix`
  is a `callPackage` function, not a top-level attribute set.
- Do not use `--use-update-script` here; that mode expects a nixpkgs checkout
  with `maintainers/scripts/update.nix`.
