{pkgs}: let
  inherit (pkgs) lib symlinkJoin makeWrapper stdenvNoCC;
in {
  buildClaudeSkill = {
    name,
    src,
  }:
    stdenvNoCC.mkDerivation {
      pname = "claude-skill-${name}";
      version = "0";
      inherit src;
      passthru.skillName = name;
      installPhase = ''
        runHook preInstall
        mkdir -p $out
        cp -r $src/. $out/
        runHook postInstall
      '';
    };

  buildClaudeCode = {
    claude-code,
    skills ? [],
    extraFlags ? [],
    binaryName ? "claude",
    extraBinaries ? [],
  }: let
    skillsBundle = stdenvNoCC.mkDerivation {
      pname = "claude-skills-bundle";
      version = "0";
      dontUnpack = true;
      installPhase = ''
        mkdir -p $out/.claude/skills
        ${lib.concatMapStringsSep "\n" (s: ''
            ln -s ${s} $out/.claude/skills/${s.skillName}
          '')
          skills}
      '';
    };
  in
    symlinkJoin {
      name = "${binaryName}-${claude-code.version or "0"}";
      paths = [claude-code];
      nativeBuildInputs = [makeWrapper];
      postBuild = ''
        wrapArgs=()

        ${lib.optionalString (skills != []) ''
          wrapArgs+=(--add-flags "--add-dir ${skillsBundle}")
        ''}

        ${lib.concatMapStrings (flag: ''
            wrapArgs+=(--add-flags ${lib.escapeShellArg flag})
          '')
          extraFlags}

        wrapProgram $out/bin/${lib.escapeShellArg binaryName} "''${wrapArgs[@]}"

        ${lib.concatMapStrings (bin: ''
            ln -sf $out/bin/${lib.escapeShellArg binaryName} $out/bin/${lib.escapeShellArg bin}
          '')
          extraBinaries}
      '';
      meta = claude-code.meta or {};
    };
}
