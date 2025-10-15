# writeFishApplication Example

Here's how to use the new `writeFishApplication` helper in your `home/common.nix`:

```nix
{
  pkgs,
  config,
  lib,
  ...
}: let
  customLib = import ../lib {inherit pkgs lib;};
in {
  # ... existing config ...

  home.packages = [
    # Example 1: Simple fish script with runtime dependencies
    (customLib.writeFishApplication {
      name = "git-cleanup";
      runtimeInputs = [pkgs.git pkgs.fzf];
      text = ''
        # Clean up merged branches interactively
        set branches (git branch --merged | grep -v '^\*' | grep -v 'main' | grep -v 'master')

        if test (count $branches) -eq 0
          echo "No merged branches to clean up"
          return 0
        end

        echo $branches | fzf --multi | xargs -r git branch -d
      '';
    })

    # Example 2: Fish script with environment variables
    (customLib.writeFishApplication {
      name = "my-dev-setup";
      runtimeInputs = [pkgs.git pkgs.nodejs];
      runtimeEnv = {
        NODE_ENV = "development";
        DEBUG = "*";
      };
      text = ''
        echo "Setting up development environment..."
        echo "Node version: "(node --version)
        echo "NODE_ENV: $NODE_ENV"
      '';
    })

    # Example 3: Script that doesn't inherit system PATH
    (customLib.writeFishApplication {
      name = "isolated-script";
      runtimeInputs = [pkgs.coreutils pkgs.ripgrep];
      inheritPath = false;  # Only use runtimeInputs in PATH
      text = ''
        # This script only has access to coreutils and ripgrep
        rg --version
      '';
    })
  ];
}
```

## Key Features

- **name**: Name of the executable
- **text**: Your Fish script (without shebang)
- **runtimeInputs**: List of packages to add to PATH (like `buildInputs` for runtime)
- **runtimeEnv**: Environment variables to set
- **fishOptions**: Fish shell options (default: `["pipefail"]`)
- **inheritPath**: Whether to include system $PATH (default: `true`)
- **checkPhase**: Custom validation (default: runs `fish --no-execute` to check syntax)

## Differences from writeShellApplication

1. Uses `fish_add_path --prepend` for PATH manipulation (Fish-native)
2. Different shell options (Fish doesn't have errexit/nounset)
3. Uses `fish --no-execute` for syntax checking instead of shellcheck
4. PATH is a list in Fish, not colon-delimited string
