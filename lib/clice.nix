{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  glibc,
}:

stdenvNoCC.mkDerivation rec {
  pname = "clice";
  version = "1.0.0";

  # Upstream release source: 92d26ad688e439961d6176cf3d30270bd898c55e.
  src = fetchurl {
    url = "https://github.com/clice-io/clice/releases/download/v${version}/clice-${version}.x86_64-unknown-linux-gnu.tar.gz";
    hash = "sha256-ndGBqsnIHK52slXpU9ohyeYD/FtAZEfrJsler2ftlpo=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ glibc ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"
    # Resource lookup is relative to bin/clice; workers re-exec the same ELF.
    cp -r bin lib clice.toml "$out/"
    install -Dm644 LICENSE "$out/share/licenses/clice/LICENSE"

    runHook postInstall
  '';

  meta = {
    description = "C++ language server with native module support";
    homepage = "https://github.com/clice-io/clice";
    license = lib.licenses.asl20;
    mainProgram = "clice";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
