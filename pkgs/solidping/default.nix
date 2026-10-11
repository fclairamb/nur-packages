{
  lib,
  stdenvNoCC,
  fetchurl,
  gzip,
}:

let
  version = "0.38.3";

  sources = {
    x86_64-linux = {
      name = "linux-amd64";
      hash = "sha256-pdfJikz6jBpQ+u82q+cpQodCYrkC3j5FVYKWzoV75g0=";
    };
    aarch64-linux = {
      name = "linux-arm64";
      hash = "sha256-J+UA2I17ru0nETtLjoUW0txuzK8WRi26egOnNSDx6ns=";
    };
    x86_64-darwin = {
      name = "darwin-amd64";
      hash = "sha256-i0V7r5XpsobP5zm0pnlTkKBHaNMIc9buV54HYbUKIo4=";
    };
    aarch64-darwin = {
      name = "darwin-arm64";
      hash = "sha256-NphhRKQeA7ueVF39SBulDByL94TqnOOWJtjTO3eug6M=";
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
    $out/bin/solidping --help | grep -q "SolidPing monitoring service"
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
