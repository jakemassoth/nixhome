#!/bin/bash
set -euo pipefail

nix run home-manager/master -- init --switch
