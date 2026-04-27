{pkgs}: let
  inherit (pkgs) lib symlinkJoin makeWrapper stdenvNoCC buildNpmPackage;
in {
  buildPiExtension = {
    src,
    name,
    version,
    npmDepsHash ? null,
    ...
  } @ args:
    if npmDepsHash != null
    then
      buildNpmPackage ({
          pname = name;
          inherit version src;
          inherit npmDepsHash;
          dontNpmBuild = true;
          installPhase = ''
            runHook preInstall
            mkdir -p $out
            cp -r . $out/
            runHook postInstall
          '';
        }
        // removeAttrs args ["name"])
    else
      stdenvNoCC.mkDerivation ({
          pname = name;
          inherit version src;
          installPhase = ''
            runHook preInstall
            mkdir -p $out
            cp -r $src/. $out/
            runHook postInstall
          '';
        }
        // removeAttrs args ["name"]);

  buildPiSkill = {
    name,
    src,
  }:
    stdenvNoCC.mkDerivation {
      pname = "pi-skill-${name}";
      version = "0";
      inherit src;
      installPhase = ''
        runHook preInstall
        mkdir -p $out/${name}
        if [ -f "$src" ]; then
          cp "$src" "$out/${name}/"
        else
          cp -r "$src/." "$out/${name}/"
        fi
        runHook postInstall
      '';
    };

  buildPiPrompt = {
    name,
    src,
  }:
    stdenvNoCC.mkDerivation {
      pname = "pi-prompt-${name}";
      version = "0";
      inherit src;
      installPhase = ''
        runHook preInstall
        mkdir -p $out
        cp "$src" "$out/${name}.md"
        runHook postInstall
      '';
    };

  buildPiTheme = {
    name,
    src,
  }:
    stdenvNoCC.mkDerivation {
      pname = "pi-theme-${name}";
      version = "0";
      inherit src;
      installPhase = ''
        runHook preInstall
        mkdir -p $out
        cp "$src" "$out/${name}.json"
        runHook postInstall
      '';
    };

  buildPi = {
    pi,
    extensions ? [],
    skills ? [],
    prompts ? [],
    themes ? [],
    env ? {},
    extraFlags ? [],
    binaryName ? "pi",
    extraBinaries ? [],
  }:
    symlinkJoin {
      name = "${binaryName}-${pi.version or "0"}";
      paths = [pi];
      nativeBuildInputs = [makeWrapper];
      postBuild = ''
        wrapArgs=()

        ${lib.concatMapStrings (ext: ''
            if [ -f "${ext}/index.ts" ]; then
              wrapArgs+=(--add-flags "--extension ${ext}/index.ts")
            elif [ -f "${ext}" ]; then
              wrapArgs+=(--add-flags "--extension ${ext}")
            else
              wrapArgs+=(--add-flags "--extension ${ext}")
            fi
          '')
          extensions}

        ${lib.concatMapStrings (skill: ''
            for skillPath in ${skill}/*; do
              [ -e "$skillPath" ] || continue
              wrapArgs+=(--add-flags "--skill $skillPath")
            done
          '')
          skills}

        ${lib.concatMapStrings (prompt: ''
            wrapArgs+=(--add-flags "--prompt-template ${prompt}")
          '')
          prompts}

        ${lib.concatMapStrings (theme: ''
            wrapArgs+=(--add-flags "--theme ${theme}")
          '')
          themes}

        ${lib.concatStrings (lib.mapAttrsToList (name: value: ''
            wrapArgs+=(--set-default ${lib.escapeShellArg name} ${lib.escapeShellArg value})
          '')
          env)}

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
      meta = pi.meta or {};
    };
}
