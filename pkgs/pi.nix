{
  pkgs,
  pi,
}: let
  buildPiLib = import ../lib/buildPi.nix {inherit pkgs;};
  inherit (buildPiLib) buildPi buildPiExtension buildPiSkill;
in
  buildPi {
    inherit pi;

    skills = [
      (buildPiSkill {
        name = "improve-harness";
        src = ../home/programs/pi/skills/improve-harness;
      })
      (buildPiSkill {
        name = "browser-tools";
        src = ../home/programs/pi/skills/browser-tools;
        npmDepsHash = "sha256-CRCAVRYM6v7aPnj+F5pLGw7pYNdO3YSSFhGbxVAPW8A=";
        # puppeteer's full package tries to download a Chromium binary on
        # install; the skill only uses puppeteer-core against system Chrome.
        npmExtraEnv = {
          PUPPETEER_SKIP_DOWNLOAD = "true";
        };
      })
      (buildPiSkill {
        name = "buycycle-gravel-search";
        src = ../home/programs/pi/skills/buycycle-gravel-search;
      })
      (buildPiSkill {
        name = "marktplaats-gravel-search";
        src = ../home/programs/pi/skills/marktplaats-gravel-search;
      })
      (buildPiSkill {
        name = "make-overview";
        src = ../home/programs/pi/skills/make-overview;
      })
    ];
  }
