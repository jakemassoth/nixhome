{
  pkgs,
  pi,
}: let
  buildPiLib = import ../lib/buildPi.nix {inherit pkgs;};
  inherit (buildPiLib) buildPi buildPiExtension buildPiSkill;
in
  buildPi {
    inherit pi;

    extensions = [
      (buildPiExtension {
        name = "pi-vertex";
        version = "1.1.4";
        src = ../home/programs/pi/extensions/pi-vertex;
        npmDepsHash = "sha256-oSsTImt76iaKEEMECb7qYS/IO54bna3EDFCLCMoLrtY=";
      })
    ];

    skills = [
      (buildPiSkill {
        name = "grill-me";
        src =
          pkgs.fetchFromGitHub {
            owner = "mattpocock";
            repo = "skills";
            rev = "383b6a06d59c4ce0ffcb14112bfd91265a86cf91";
            hash = "sha256-zeXdZQEpMfFjzSL/yrRYJZC2aOBvlY8xE3Ol4GMGyJI=";
          }
          + "/skills/grill-me";
      })
      (buildPiSkill {
        name = "to-prd";
        src = ../home/programs/pi/skills/to-prd;
      })
    ];

    env = {
      GOOGLE_CLOUD_PROJECT = "jake-index-demo";
      GOOGLE_CLOUD_LOCATION = "global";
    };
  }
