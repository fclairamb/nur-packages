{
  lib,
  stdenvNoCC,
  fetchurl,
  gzip,
}:

let
  version = "0.38.6";

  sources = {
    x86_64-linux = {
      name = "linux-amd64";
      hash = "sha256-/CxBVCngLLDRNpeo/lIWLtOjEw0m3+k0j4aNVAsz9wY=";
    };
    aarch64-linux = {
      name = "linux-arm64";
      hash = "sha256-hnN65emow3Lfm2/MEHDOIyG2vWne/RK6dwGsdnphjf0=";
    };
    x86_64-darwin = {
      name = "darwin-amd64";
      hash = "sha256-3HC8FowZ5OPv8E068iHl+ozfHyHxZGR2SoTjq0Jn/bI=";
    };
    aarch64-darwin = {
      name = "darwin-arm64";
      hash = "sha256-DXLN28hyGUS9R5dWWpwmba1z9hVv3jTpEuR9hg7jhhk=";
    };
  };

  source =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "solidping: unsupported system ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "solidping";
  inherit version;

  src = fetchurl {
    url = "https://github.com/fclairamb/solidping/releases/download/v${version}/solidping-${source.name}.gz";
    inherit (source) hash;
  };

  nativeBuildInputs = [ gzip ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  # Prebuilt, statically linked Go binary.
  dontStrip = true;
  dontPatchELF = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    gzip -dc $src > $out/bin/solidping
    chmod 755 $out/bin/solidping
    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    $out/bin/solidping --help > help.txt
    grep "SolidPing monitoring service" help.txt
    runHook postInstallCheck
  '';

  meta = {
    description = "Self-hosted uptime and synthetic monitoring with status pages, incidents and alerting";
    homepage = "https://www.solidping.io";
    downloadPage = "https://github.com/fclairamb/solidping/releases";
    changelog = "https://github.com/fclairamb/solidping/releases/tag/v${version}";
    license = lib.licenses.agpl3Only;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = builtins.attrNames sources;
    mainProgram = "solidping";
  };
}
