{
  buildNpmPackage,
  src,
}:
buildNpmPackage {
  pname = "pi-vertex";
  version = "1.1.4";
  inherit src;
  npmDepsHash = "sha256-oSsTImt76iaKEEMECb7qYS/IO54bna3EDFCLCMoLrtY=";
  dontNpmBuild = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r . $out/
    runHook postInstall
  '';
}
