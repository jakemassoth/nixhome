{
  symlinkJoin,
  makeWrapper,
  pi,
  pi-vertex,
}:
symlinkJoin {
  name = "pi-with-vertex-${pi.version or "0"}";
  paths = [pi];
  nativeBuildInputs = [makeWrapper];
  postBuild = ''
    wrapProgram $out/bin/pi \
      --add-flags "--extension ${pi-vertex}/index.ts"
  '';
  meta = pi.meta or {};
}
