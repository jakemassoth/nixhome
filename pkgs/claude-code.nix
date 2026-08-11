{
  pkgs,
  claude-code,
}: let
  buildLib = import ../lib/buildClaudeCode.nix {inherit pkgs;};
  inherit (buildLib) buildClaudeCode buildClaudeSkill;
in
  buildClaudeCode {
    inherit claude-code;

    skills = [
      (buildClaudeSkill {
        name = "browser-tools";
        src = ../home/programs/pi/skills/browser-tools;
        npmDepsHash = "sha256-CRCAVRYM6v7aPnj+F5pLGw7pYNdO3YSSFhGbxVAPW8A=";
        # puppeteer's full package tries to download a Chromium binary on
        # install; the skill only uses puppeteer-core against system Chrome.
        npmExtraEnv = {
          PUPPETEER_SKIP_DOWNLOAD = "true";
        };
      })
    ];
  }
