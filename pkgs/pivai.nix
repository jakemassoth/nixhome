{
  symlinkJoin,
  makeWrapper,
  pi,
  pi-vertex,
}:
symlinkJoin {
  name = "pivai-${pi.version or "0"}";
  paths = [pi];
  nativeBuildInputs = [makeWrapper];
  postBuild = ''
    wrapProgram $out/bin/pi \
      --add-flags "--extension ${pi-vertex}/index.ts" \
      --set-default GOOGLE_CLOUD_PROJECT "jake-index-demo" \
      --set-default GOOGLE_CLOUD_LOCATION "global"

    # also expose as 'pivai' for convenience
    ln -s $out/bin/pi $out/bin/pivai
  '';
  meta = pi.meta or {};
}
