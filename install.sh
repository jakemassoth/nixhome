#!/usr/bin/env bash
set -euo pipefail

nix run home-manager/master -- switch --flake .#devcontainer --impure
