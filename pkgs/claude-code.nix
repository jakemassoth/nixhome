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
        name = "to-prd";
        src = ../home/programs/pi/skills/to-prd;
      })
      (buildClaudeSkill {
        name = "improve-harness";
        src = ../home/programs/pi/skills/improve-harness;
      })
      (buildClaudeSkill {
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
    ];
  }
