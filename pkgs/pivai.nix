{
  writeShellScriptBin,
  pi,
}:
writeShellScriptBin "pivai" ''
  export GOOGLE_CLOUD_PROJECT="''${GOOGLE_CLOUD_PROJECT:-jake-index-demo}"
  export GOOGLE_CLOUD_LOCATION="''${GOOGLE_CLOUD_LOCATION:-global}"
  exec ${pi}/bin/pi "$@"
''
