{
  lib,
  stdenv,
  fish,
  runCommand,
  writeTextFile,
}:
# writeFishApplication is similar to writeShellApplication but for Fish scripts
# It handles PATH setup and provides optional fish syntax checking
{
  name,
  text,
  runtimeInputs ? [],
  runtimeEnv ? null,
  inheritPath ? true,
  checkPhase ? null,
  meta ? {},
  derivationArgs ? {},
}:
writeTextFile {
  inherit name meta derivationArgs;

  executable = true;

  destination = "/bin/${name}";

  allowSubstitutes = true;
  preferLocalBuild = false;

  text =
    ''
      #!${fish}/bin/fish
    ''
    + lib.optionalString (runtimeEnv != null) ''

      ${lib.toShellVars runtimeEnv}
    ''
    + lib.optionalString (runtimeInputs != []) ''

      # Add runtime inputs to PATH
      fish_add_path --prepend ${lib.concatMapStringsSep " " (input: "${input}/bin") runtimeInputs}
    ''
    + lib.optionalString (!inheritPath && runtimeInputs != []) ''

      # Clear inherited PATH since inheritPath is false
      set -gx PATH ${lib.concatMapStringsSep " " (input: "${input}/bin") runtimeInputs}
    ''
    + ''

      ${text}
    '';

  checkPhase =
    if checkPhase == null
    then ''
      runHook preCheck
      ${fish}/bin/fish --no-execute "$target"
      runHook postCheck
    ''
    else checkPhase;
}
