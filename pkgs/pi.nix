{ pkgs, pi }:

let
  buildPiLib = import ../lib/buildPi.nix { inherit pkgs; };
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
      src = pkgs.fetchFromGitHub {
        owner = "mattpocock";
        repo = "skills";
        rev = "main";
        hash = "sha256-+6C7uTbdCyGz/VjU15zqALzRrrWI2/0I3mhEmwdUHDg=";
      } + "/grill-me";
    })
  ];

  env = {
    GOOGLE_CLOUD_PROJECT = "jake-index-demo";
    GOOGLE_CLOUD_LOCATION = "global";
  };
}
