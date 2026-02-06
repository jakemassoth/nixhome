{
  lib,
  stdenvNoCC,
  fetchurl,
  nodejs,
  makeBinaryWrapper,
  unzip,
  typescript,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "angular-language-server";
  version = "21.1.1";
  src = fetchurl {
    name = "angular-language-server-${finalAttrs.version}.zip";
    url = "https://github.com/angular/angular/releases/download/vsix-${finalAttrs.version}/ng-template-${finalAttrs.version}.vsix";
    hash = "sha256:a3c34ec903859d6fec69bc2fc9e21870ec6d3b3f6c2ac207a91226913d4c6f3b";
  };

  nativeBuildInputs = [
    unzip
    makeBinaryWrapper
  ];

  buildInputs = [nodejs];

  installPhase = ''
    runHook preInstall
    install -Dm555 server/bin/ngserver $out/lib/bin/ngserver
    install -Dm444 server/index.js $out/lib/index.js
    mkdir -p $out/lib/node_modules
    cp -r node_modules/* $out/lib/node_modules
    # do not use vendored typescript
    rm -rf $out/lib/node_modules/typescript
    runHook postInstall
  '';

  postFixup = ''
    patchShebangs $out/lib/bin/ngserver $out/lib/index.js $out/lib/node_modules
    makeWrapper $out/lib/bin/ngserver $out/bin/ngserver \
      --prefix PATH : ${lib.makeBinPath [nodejs]} \
      --add-flags "--tsProbeLocations ${typescript}/lib/node_modules/typescript --ngProbeLocations $out/lib/node_modules"
  '';

  meta = {
    mainProgram = "ngserver";
  };
})
